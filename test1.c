//Source Code (main.c)
//  PIC16F877A Robot - ( 8MHz)
//
//  Stages we implemented:
//    1) Line follower
//    2) Tunnel (LDR detects dark, buzzer ON)
//    3) Obstacle / wall follow until line appears again
//    4) Line boost + detect parking area (solid black area)
//    5) Parking:
//         - enter a little forward
//         - turn right once to align
//         - creep forward while curving right (arc)
//         - stop when ultrasonic is close enough
//         - LED OFF + raise servo flag
//
//  Important  we followed (as required):
//    - NO Delay_ms() / Delay_us()
//    - ADC is custom (no mikroC ADC library)
//    - ms timing comes from Timer0 interrupt
//    - us timing comes from Timer1 (ultrasonic + servo)

volatile unsigned long ms_ticks = 0;     // counts milliseconds (our main timer)
volatile unsigned int  ms = 0;           // extra counter (kept for consistency)
unsigned int servo_i;                   // used in servo loop

// ---------------- Timer0 1ms interrupt tick ----------------
// OPTION_REG = 0xC2 -> internal clock, prescaler 1:8
// TMR0 preload = 6 gives ~1ms overflow at 8MHz (this worked stable in testing)
void timer0_init_1ms_int(void)
{
    OPTION_REG = 0xC2;
    TMR0 = 6;
    INTCON &= (unsigned char)~0x04;     // clear T0IF
    INTCON |= 0x20;                    // enable Timer0 interrupt
    INTCON |= 0x80;                    // enable global interrupt
}

void my_delay_init(void)
{
    ms_ticks = 0;
    ms = 0;
    timer0_init_1ms_int();
}

// Our replacement for Delay_ms(): just wait using ms_ticks
void my_delay(unsigned int ms_local)
{
    unsigned long start = ms_ticks;
    while ((unsigned long)(ms_ticks - start) < (unsigned long)ms_local) { }
}

// Only Timer0 interrupt is used here (we kept ISR clean on purpose)
void interrupt()
{
    if (INTCON & 0x04) {
        TMR0 = 6;
        INTCON &= (unsigned char)~0x04;
        ms_ticks++;
        ms++;
    }
}

// ---------------- Custom ADC (AN0 / RA0) ----------------
// LDR is connected to AN0 so we read brightness from ADC
void ADC_Init_Custom(void)
{
    ADCON1 = 0x80;   // right-justified, Vref = Vdd/Vss
    ADCON0 = 0x41;   // ADC ON, AN0 selected, Fosc/8
}

unsigned int read_adc(void)
{
    ADCON0 |= 0x04;                 // start conversion
    while (ADCON0 & 0x04) { }       // wait until done
    return ((unsigned int)ADRESH << 8) | (unsigned int)ADRESL;
}

// ---------------- Pins / masks ----------------
#define OBS_LO_MASK  0x01           // RD0 obstacle IR (near)
#define OBS_HI_MASK  0x02           // RD1 obstacle IR (far)

#define IR_R_MASK    0x04           // RD2 right line sensor
#define IR_L_MASK    0x08           // RD3 left  line sensor

#define LED_MASK     0x10           // RD4 LED

#define START_MASK   0x01           // RB0 start button (active low)
#define BUZZ_MASK    0x02           // RB1 buzzer
#define TRIG_MASK    0x40           // RB6 ultrasonic trig
#define ECHO_MASK    0x80           // RB7 ultrasonic echo

#define RM_FWD_MASK  0x01           // RC0 right motor forward
#define RM_BWD_MASK  0x08           // RC3 right motor backward
#define LM_FWD_MASK  0x10           // RC4 left  motor forward
#define LM_BWD_MASK  0x20           // RC5 left  motor backward
#define DIR_MASK     0x39           // direction pins mask

// ---------------- Servo flag on RC6 ----------------
// We send a repeated 20ms frame with a high pulse to raise the flag
#define SERVO_MASK      0x40
#define SERVO_HIGH_US   2350        // raised a bit more than before
#define SERVO_FRAME_US  20000

// ---------------- Speeds (these are the tuned values) ----------------
#define SPD_FWD      90
#define SPD_FAST     110
#define SPD_SLOW     10

#define SPD_FWD_B    110
#define SPD_FAST_B   150
#define SPD_SLOW_B   35

#define OBS_FWD      90
#define OBS_FAST     110
#define OBS_SLOW     25

#define PARK_FWD     60
#define PARK_FAST    70
#define PARK_SLOW    40

// ---------------- Timing constants ----------------
#define START_DELAY_MS            3000

#define INTERSECT_PAUSE_MS         500
#define INTERSECT_TURN_MS          350   // makes intersection turn harder

#define STOP_BEFORE_TURN_MS         80
#define WALL_SOFT_TURN_MS           70
#define WALL_VERY_SLIGHT_MS         35
#define TURN_90_MS                 640

// Parking entry: go inside first then align right
#define PARK_ENTRY_FORWARD_MS      260
#define PARK_ENTRY_TURN_MS         380
#define PARK_ENTRY_SETTLE_MS        60

// Parking creep: keep moving but curve right
#define PARK_ARC_LEFT_SPEED        73    // left wheel stronger
#define PARK_ARC_RIGHT_SPEED       45    // right wheel still moving
#define PARK_ARC_PULSE_MS          30

// Tunnel detection (LDR)
#define LDR_DARK_TH                450
#define TUNNEL_EXIT_STABLE_COUNT    40

#define TUN_FWD      140
#define TUN_FAST     200
#define TUN_SLOW     30

// Ultrasonic thresholds
#define US_THRESH_CM               20
#define PARK_STOP_CM               13

// Parking black-area detection (both sensors black for ~200ms)
#define PARK_LINE_COUNT            40

// Parking beep pattern
#define BEEP_PERIOD_MS           1000
#define BEEP_ON_MS                120

// IR obstacle module is active-low in our setup
#define OBS_ACTIVE_LOW              1

// Stages (state machine)
#define STAGE_LINE        0
#define STAGE_TUNNEL      1
#define STAGE_OBSTACLE    2
#define STAGE_LINE_BOOST  3
#define STAGE_PARKING     4
#define STAGE_DONE        5

// ---------------- Small helper functions ----------------
void led_on()  { PORTD |= LED_MASK; }
void led_off() { PORTD &= (unsigned char)(~LED_MASK); }

void buz_on()  { PORTB |= BUZZ_MASK; }
void buz_off() { PORTB &= (unsigned char)(~BUZZ_MASK); }

// Set both motors to forward direction (we only change speeds after this)
void set_forward_dir()
{
    PORTC = (PORTC & (unsigned char)(~DIR_MASK)) | (RM_FWD_MASK | LM_FWD_MASK);
}

// Stop everything (direction pins + PWM)
void stop_both()
{
    PORTC &= (unsigned char)(~DIR_MASK);
    CCPR1L = 0;
    CCPR2L = 0;
}

// Small brake before obstacle turning (helps the robot not drift)
void stop_before_turn_obstacle()
{
    stop_both();
    my_delay(STOP_BEFORE_TURN_MS);
}

// ---------------- PWM setup (CCP1 + CCP2) ----------------
void CCPPWM_init(void)
{
    CCP1CON = 0x0C;  // PWM mode
    CCP2CON = 0x0C;
    PR2 = 250;       // PWM period
    CCPR1L = 125;
    CCPR2L = 125;
    T2CON  = 0x06;   // Timer2 ON, prescaler 1:16
}

// NOTE: we kept these names as-is so we don’t break anything
void motor_L(unsigned char speed){ CCPR1L = speed; }
void motor_R(unsigned char speed){ CCPR2L = speed; }

// ---------------- Timer1 microsecond delay ----------------
// We use Timer1 for anything that needs microsecond accuracy (servo + ultrasonic)
unsigned int tmr1_read_16(void)
{
    unsigned char l = TMR1L;
    unsigned char h = TMR1H;
    return ((unsigned int)h << 8) | (unsigned int)l;
}

void my_delay_us(unsigned int us_local)
{
    unsigned int start;

    // stop Timer1
    T1CON &= (unsigned char)~0x01;

    // internal clock + prescaler 1:2 => 1us per tick at 8MHz
    T1CON &= (unsigned char)~(0x02 | 0x30);
    T1CON |= 0x10;

    // clear counter
    TMR1H = 0;
    TMR1L = 0;

    // start Timer1
    T1CON |= 0x01;

    start = tmr1_read_16();
    while ((unsigned int)(tmr1_read_16() - start) < us_local) { }

    // stop Timer1
    T1CON &= (unsigned char)~0x01;
}

// ---------------- Servo flag raise ----------------
// We send around 100 frames so the servo has enough time to physically move
void raise_servo_flag(void)
{
    unsigned int high_us = SERVO_HIGH_US;

    for (servo_i = 0; servo_i < 100; servo_i++) {
        PORTC |= SERVO_MASK;                         // HIGH pulse
        my_delay_us(high_us);
        PORTC &= (unsigned char)~SERVO_MASK;         // LOW rest of the frame
        my_delay_us((unsigned int)(SERVO_FRAME_US - high_us));
    }
}

// ---------------- Ultrasonic distance in cm ----------------
// HC-SR04 style: TRIG 10us, then measure ECHO high time
unsigned int ultrasonic_cm(void)
{
    unsigned int timeout;
    unsigned int t;

    // configure Timer1 as 1us tick (same style as our delay)
    T1CON &= (unsigned char)~0x01;
    T1CON &= (unsigned char)~(0x02 | 0x30);
    T1CON |= 0x10;

    // clear
    TMR1H = 0;
    TMR1L = 0;

    // TRIG pulse
    PORTB |= TRIG_MASK;
    my_delay_us(10);
    PORTB &= (unsigned char)~TRIG_MASK;

    // wait for ECHO rising (timeout safety)
    timeout = 0;
    while (!(PORTB & ECHO_MASK)) {
        if (timeout++ > 30000) return 0xFFFF;
    }

    // measure HIGH pulse
    TMR1H = 0;
    TMR1L = 0;
    T1CON |= 0x01;

    timeout = 0;
    while (PORTB & ECHO_MASK) {
        if (timeout++ > 60000) break;
    }

    T1CON &= (unsigned char)~0x01;

    t = (((unsigned int)TMR1H << 8) | TMR1L);
    return (unsigned int)(t / 58);   // convert us -> cm
}

// ---------------- Sensor helpers ----------------
unsigned char ir_detect(unsigned char mask)
{
#if OBS_ACTIVE_LOW
    return ((PORTD & mask) == 0);    // active low module
#else
    return ((PORTD & mask) != 0);
#endif
}

// these are raw checks (we keep them as-is because the robot is tuned this way)
unsigned char line_both_black_raw()
{
    unsigned char both = (unsigned char)(IR_L_MASK | IR_R_MASK);
    return ((PORTD & both) == both);
}
unsigned char line_any_black_raw()
{
    return ((PORTD & (IR_L_MASK | IR_R_MASK)) != 0);
}

// ---------------- Line follow logic ----------------
// (We kept the same inversion because our sensors behaved like that.)
void do_line_follow(unsigned char fwd, unsigned char fast, unsigned char slow)
{
    unsigned char left  = (PORTD & IR_L_MASK) ? 0 : 1;
    unsigned char right = (PORTD & IR_R_MASK) ? 0 : 1;

    set_forward_dir();

    if (left==1 && right==1) {
        motor_L(fwd); motor_R(fwd);
    } else if (left==1 && right==0) {
        motor_L(fast); motor_R(slow);
    } else if (left==0 && right==1) {
        motor_L(slow); motor_R(fast);
    } else {
        // intersection case: we pause then do a right turn
        stop_both();
        my_delay(INTERSECT_PAUSE_MS);

        set_forward_dir();
        motor_L(0);
        motor_R(fast);
        my_delay(INTERSECT_TURN_MS);
    }
}

// Boost stage: no intersection turning (we just want to keep moving)
void do_line_follow_no_intersection(unsigned char fwd, unsigned char fast, unsigned char slow)
{
    unsigned char left  = (PORTD & IR_L_MASK) ? 0 : 1;
    unsigned char right = (PORTD & IR_R_MASK) ? 0 : 1;

    set_forward_dir();

    if (left==1 && right==1) {
        motor_L(fwd); motor_R(fwd);
    } else if (left==1 && right==0) {
        motor_L(fast); motor_R(slow);
    } else if (left==0 && right==1) {
        motor_L(slow); motor_R(fast);
    } else {
        motor_L(slow);
        motor_R(slow);
    }
}

// ---------------- Obstacle / wall follow moves ----------------
void obs_forward()
{
    set_forward_dir();
    motor_L(OBS_FWD);
    motor_R(OBS_FWD);
}
void obs_soft_left()
{
    set_forward_dir();
    motor_L(OBS_SLOW);
    motor_R(OBS_FAST);
    my_delay(WALL_SOFT_TURN_MS);
}
void obs_soft_right()
{
    set_forward_dir();
    motor_L(OBS_FAST);
    motor_R(OBS_SLOW);
    my_delay(WALL_SOFT_TURN_MS);
}
void obs_very_slight_left()
{
    set_forward_dir();
    motor_L(OBS_SLOW);
    motor_R(OBS_FAST);
    my_delay(WALL_VERY_SLIGHT_MS);
}

// This is used once when we enter obstacle mode, to make the robot face the wall properly
void pivot_right_90()
{
    set_forward_dir();
    motor_L(OBS_FAST);
    motor_R(0);
    my_delay(TURN_90_MS);
    stop_both();
    my_delay(80);
}

// ---------------- Parking motion ----------------
void park_forward()
{
    set_forward_dir();
    motor_L(PARK_FWD);
    motor_R(PARK_FWD);
}

// We creep with a right arc: both wheels move, but left is faster
void park_creep_arc_right_pulse(void)
{
    set_forward_dir();
    motor_L(PARK_ARC_LEFT_SPEED);
    motor_R(PARK_ARC_RIGHT_SPEED);
    my_delay(PARK_ARC_PULSE_MS);
}

// Entry: go forward into the area first, then align right once
void park_entry_sequence_once(void)
{
    set_forward_dir();
    motor_L(PARK_FWD);
    motor_R(PARK_FWD);
    my_delay(PARK_ENTRY_FORWARD_MS);

    motor_L(PARK_FAST);
    motor_R(PARK_SLOW);
    my_delay(PARK_ENTRY_TURN_MS);

    motor_L(PARK_SLOW);
    motor_R(PARK_SLOW);
    my_delay(PARK_ENTRY_SETTLE_MS);
}

// ================================================================
// MAIN PROGRAM
// ================================================================
void main()
{
    unsigned char running = 0;
    unsigned char stage = STAGE_LINE;

    unsigned int ldr, dist;
    unsigned char in_tunnel = 0;
    unsigned char exit_count = 0;

    unsigned char post_tunnel_init_done = 0;

    unsigned int park_line_cnt = 0;

    unsigned long beep_start = 0;
    unsigned long beep_off_at = 0;

    unsigned char park_stop_stable = 0;
    unsigned char did_park_entry_turn = 0;

    // I/O directions
    TRISA = 0x01;   // RA0 ADC input
    TRISB = 0x81;   // RB0 button, RB7 echo
    TRISC = 0x00;   // motors + servo
    TRISD = 0x0F;   // sensors on RD0..RD3, LED on RD4

    // ultrasonic pins
    TRISB &= (unsigned char)~0x40;  // RB6 TRIG output
    TRISB |= 0x80;                  // RB7 ECHO input

    PORTA=0; PORTB=0; PORTC=0; PORTD=0;

    ADC_Init_Custom();
    CCPPWM_init();
    stop_both();
    led_off();
    buz_off();

    // servo line idle low
    PORTC &= (unsigned char)~SERVO_MASK;

    my_delay_init();

    while(1)
    {
        // ---------------- Start button (toggle run/stop) ----------------
        if ((PORTB & START_MASK) == 0) {
            my_delay(40);
            if ((PORTB & START_MASK) == 0) {
                while ((PORTB & START_MASK) == 0) { }
                my_delay(40);

                running = !running;

                if (running) {
                    stop_both();
                    buz_off();
                    led_off();

                    // reset everything for a fresh run
                    stage = STAGE_LINE;
                    in_tunnel = 0;
                    exit_count = 0;
                    post_tunnel_init_done = 0;
                    park_line_cnt = 0;

                    beep_start = ms_ticks;
                    beep_off_at = 0;

                    park_stop_stable = 0;
                    did_park_entry_turn = 0;

                    // small delay before movement (lets us place the robot correctly)
                    my_delay(START_DELAY_MS);
                    led_on();
                } else {
                    stop_both();
                    buz_off();
                    led_off();
                }
            }
        }

        if (!running) { stop_both(); buz_off(); continue; }

        // ================= STAGE 1: LINE FOLLOW =================
        stage = STAGE_LINE;
        while(1){
            ldr = read_adc();
            in_tunnel = (ldr > LDR_DARK_TH) ? 1 : 0;
            if (in_tunnel) { stage = STAGE_TUNNEL; break; }

            buz_off();
            do_line_follow(SPD_FWD, SPD_FAST, SPD_SLOW);
            my_delay(5);
        }

        // ================= STAGE 2: TUNNEL =================
        // buzzer ON here so the doctor can clearly see we are in tunnel stage
        exit_count = 0;
        while(1){
            ldr = read_adc();
            in_tunnel = (ldr > LDR_DARK_TH) ? 1 : 0;

            buz_on();
            do_line_follow(TUN_FWD, TUN_FAST, TUN_SLOW);

            // leave tunnel only after stable bright readings (to avoid noise)
            if (!in_tunnel) {
                if (exit_count < 255) exit_count++;
                if (exit_count >= TUNNEL_EXIT_STABLE_COUNT) { stage = STAGE_OBSTACLE; break; }
            } else {
                exit_count = 0;
            }

            my_delay(5);
        }
        buz_off();

        // ================= STAGE 3: OBSTACLE =================
        post_tunnel_init_done = 0;
        while(1){

            // the moment we detect line again, obstacle mode is finished
            if (line_any_black_raw()) {
                stage = STAGE_LINE_BOOST;
                park_line_cnt = 0;
                break;
            }

            // first time only: pivot and approach until high sensor is detected
            if (!post_tunnel_init_done) {
                stop_before_turn_obstacle();
                pivot_right_90();

                while (!ir_detect(OBS_HI_MASK)) {
                    dist = ultrasonic_cm();
                    if ((dist != 0xFFFF) && (dist < US_THRESH_CM)) {
                        stop_before_turn_obstacle();
                        obs_soft_left();
                    } else {
                        obs_forward();
                    }
                    my_delay(5);
                }

                post_tunnel_init_done = 1;
                my_delay(50);
                continue;
            }

            // normal wall following using obstacle sensors + ultrasonic
            {
                unsigned char low  = ir_detect(OBS_LO_MASK);
                unsigned char high = ir_detect(OBS_HI_MASK);

                dist = ultrasonic_cm();

                if ((dist != 0xFFFF) && (dist < US_THRESH_CM)) {
                    stop_before_turn_obstacle();
                    obs_soft_left();
                }
                else if (low) {
                    stop_before_turn_obstacle();
                    obs_very_slight_left();
                }
                else if (high) {
                    obs_forward();
                }
                else {
                    stop_before_turn_obstacle();
                    obs_soft_right();
                }
            }

            my_delay(5);
        }

        // ================= STAGE 4: LINE BOOST =================
        while(stage == STAGE_LINE_BOOST){

            buz_off();

            // parking detection: both sensors black for enough time
            if (line_both_black_raw()) {
                if (park_line_cnt < 60000) park_line_cnt++;
            } else {
                if (park_line_cnt > 0) park_line_cnt--;
            }

            if (park_line_cnt >= PARK_LINE_COUNT) {
                stage = STAGE_PARKING;
                park_line_cnt = 0;

                // reset parking timing + flags
                beep_start = ms_ticks;
                beep_off_at = 0;
                park_stop_stable = 0;
                did_park_entry_turn = 0;

                buz_off();
                break;
            }

            do_line_follow_no_intersection(SPD_FWD_B, SPD_FAST_B, SPD_SLOW_B);
            my_delay(5);
        }

        // ================= STAGE 5: PARKING =================
        while(stage == STAGE_PARKING){

            // do entry sequence only once (we don’t want it repeating)
            if (!did_park_entry_turn) {
                did_park_entry_turn = 1;
                park_entry_sequence_once();
            }

            // beep pattern during parking (1 second period, short beep)
            if ((unsigned long)(ms_ticks - beep_start) >= (unsigned long)BEEP_PERIOD_MS) {
                beep_start = ms_ticks;
                buz_on();
                beep_off_at = ms_ticks + (unsigned long)BEEP_ON_MS;
            }
            if (beep_off_at != 0 && (unsigned long)(ms_ticks) >= beep_off_at) {
                buz_off();
                beep_off_at = 0;
            }

            // ultrasonic stop with stability counter (avoid random bad readings)
            dist = ultrasonic_cm();
            if ((dist != 0xFFFF) && (dist <= PARK_STOP_CM)) {
                if (park_stop_stable < 10) park_stop_stable++;
            } else {
                park_stop_stable = 0;
            }

            // if close enough to wall, finish parking
            if (park_stop_stable >= 10) {
                stop_both();
                buz_off();
                led_off();

                raise_servo_flag();

                stage = STAGE_DONE;
                break;
            }

            // creep forward in a right arc until we reach the wall
            park_creep_arc_right_pulse();

            my_delay(5);
        }

        // ================= DONE =================
        // after we finish, we stay stopped (project requirement)
        while(stage == STAGE_DONE){
            stop_both();
            buz_off();
            led_off();
            PORTC &= (unsigned char)~SERVO_MASK;
        }
    }
}
