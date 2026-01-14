
_timer0_init_1ms_int:

;test1.c,29 :: 		void timer0_init_1ms_int(void)
;test1.c,31 :: 		OPTION_REG = 0xC2;
	MOVLW      194
	MOVWF      OPTION_REG+0
;test1.c,32 :: 		TMR0 = 6;
	MOVLW      6
	MOVWF      TMR0+0
;test1.c,33 :: 		INTCON &= (unsigned char)~0x04;     // clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;test1.c,34 :: 		INTCON |= 0x20;                    // enable Timer0 interrupt
	BSF        INTCON+0, 5
;test1.c,35 :: 		INTCON |= 0x80;                    // enable global interrupt
	BSF        INTCON+0, 7
;test1.c,36 :: 		}
L_end_timer0_init_1ms_int:
	RETURN
; end of _timer0_init_1ms_int

_my_delay_init:

;test1.c,38 :: 		void my_delay_init(void)
;test1.c,40 :: 		ms_ticks = 0;
	CLRF       _ms_ticks+0
	CLRF       _ms_ticks+1
	CLRF       _ms_ticks+2
	CLRF       _ms_ticks+3
;test1.c,41 :: 		ms = 0;
	CLRF       _ms+0
	CLRF       _ms+1
;test1.c,42 :: 		timer0_init_1ms_int();
	CALL       _timer0_init_1ms_int+0
;test1.c,43 :: 		}
L_end_my_delay_init:
	RETURN
; end of _my_delay_init

_my_delay:

;test1.c,46 :: 		void my_delay(unsigned int ms_local)
;test1.c,48 :: 		unsigned long start = ms_ticks;
	MOVF       _ms_ticks+0, 0
	MOVWF      R9+0
	MOVF       _ms_ticks+1, 0
	MOVWF      R9+1
	MOVF       _ms_ticks+2, 0
	MOVWF      R9+2
	MOVF       _ms_ticks+3, 0
	MOVWF      R9+3
;test1.c,49 :: 		while ((unsigned long)(ms_ticks - start) < (unsigned long)ms_local) { }
L_my_delay0:
	MOVF       _ms_ticks+0, 0
	MOVWF      R5+0
	MOVF       _ms_ticks+1, 0
	MOVWF      R5+1
	MOVF       _ms_ticks+2, 0
	MOVWF      R5+2
	MOVF       _ms_ticks+3, 0
	MOVWF      R5+3
	MOVF       R9+0, 0
	SUBWF      R5+0, 1
	MOVF       R9+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+1, 0
	SUBWF      R5+1, 1
	MOVF       R9+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+2, 0
	SUBWF      R5+2, 1
	MOVF       R9+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+3, 0
	SUBWF      R5+3, 1
	MOVF       FARG_my_delay_ms_local+0, 0
	MOVWF      R1+0
	MOVF       FARG_my_delay_ms_local+1, 0
	MOVWF      R1+1
	CLRF       R1+2
	CLRF       R1+3
	MOVF       R1+3, 0
	SUBWF      R5+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__my_delay123
	MOVF       R1+2, 0
	SUBWF      R5+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__my_delay123
	MOVF       R1+1, 0
	SUBWF      R5+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__my_delay123
	MOVF       R1+0, 0
	SUBWF      R5+0, 0
L__my_delay123:
	BTFSC      STATUS+0, 0
	GOTO       L_my_delay1
	GOTO       L_my_delay0
L_my_delay1:
;test1.c,50 :: 		}
L_end_my_delay:
	RETURN
; end of _my_delay

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;test1.c,53 :: 		void interrupt()
;test1.c,55 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt2
;test1.c,56 :: 		TMR0 = 6;
	MOVLW      6
	MOVWF      TMR0+0
;test1.c,57 :: 		INTCON &= (unsigned char)~0x04;
	MOVLW      251
	ANDWF      INTCON+0, 1
;test1.c,58 :: 		ms_ticks++;
	MOVF       _ms_ticks+0, 0
	MOVWF      R0+0
	MOVF       _ms_ticks+1, 0
	MOVWF      R0+1
	MOVF       _ms_ticks+2, 0
	MOVWF      R0+2
	MOVF       _ms_ticks+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _ms_ticks+0
	MOVF       R0+1, 0
	MOVWF      _ms_ticks+1
	MOVF       R0+2, 0
	MOVWF      _ms_ticks+2
	MOVF       R0+3, 0
	MOVWF      _ms_ticks+3
;test1.c,59 :: 		ms++;
	MOVF       _ms+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _ms+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _ms+0
	MOVF       R0+1, 0
	MOVWF      _ms+1
;test1.c,60 :: 		}
L_interrupt2:
;test1.c,61 :: 		}
L_end_interrupt:
L__interrupt125:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_ADC_Init_Custom:

;test1.c,65 :: 		void ADC_Init_Custom(void)
;test1.c,67 :: 		ADCON1 = 0x80;   // right-justified, Vref = Vdd/Vss
	MOVLW      128
	MOVWF      ADCON1+0
;test1.c,68 :: 		ADCON0 = 0x41;   // ADC ON, AN0 selected, Fosc/8
	MOVLW      65
	MOVWF      ADCON0+0
;test1.c,69 :: 		}
L_end_ADC_Init_Custom:
	RETURN
; end of _ADC_Init_Custom

_read_adc:

;test1.c,71 :: 		unsigned int read_adc(void)
;test1.c,73 :: 		ADCON0 |= 0x04;                 // start conversion
	BSF        ADCON0+0, 2
;test1.c,74 :: 		while (ADCON0 & 0x04) { }       // wait until done
L_read_adc3:
	BTFSS      ADCON0+0, 2
	GOTO       L_read_adc4
	GOTO       L_read_adc3
L_read_adc4:
;test1.c,75 :: 		return ((unsigned int)ADRESH << 8) | (unsigned int)ADRESL;
	MOVF       ADRESH+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	MOVF       R4+0, 0
	MOVWF      R2+1
	CLRF       R2+0
	MOVF       ADRESL+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R2+0, 0
	IORWF      R0+0, 1
	MOVF       R2+1, 0
	IORWF      R0+1, 1
;test1.c,76 :: 		}
L_end_read_adc:
	RETURN
; end of _read_adc

_led_on:

;test1.c,173 :: 		void led_on()  { PORTD |= LED_MASK; }
	BSF        PORTD+0, 4
L_end_led_on:
	RETURN
; end of _led_on

_led_off:

;test1.c,174 :: 		void led_off() { PORTD &= (unsigned char)(~LED_MASK); }
	MOVLW      239
	ANDWF      PORTD+0, 1
L_end_led_off:
	RETURN
; end of _led_off

_buz_on:

;test1.c,176 :: 		void buz_on()  { PORTB |= BUZZ_MASK; }
	BSF        PORTB+0, 1
L_end_buz_on:
	RETURN
; end of _buz_on

_buz_off:

;test1.c,177 :: 		void buz_off() { PORTB &= (unsigned char)(~BUZZ_MASK); }
	MOVLW      253
	ANDWF      PORTB+0, 1
L_end_buz_off:
	RETURN
; end of _buz_off

_set_forward_dir:

;test1.c,180 :: 		void set_forward_dir()
;test1.c,182 :: 		PORTC = (PORTC & (unsigned char)(~DIR_MASK)) | (RM_FWD_MASK | LM_FWD_MASK);
	MOVLW      198
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      17
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;test1.c,183 :: 		}
L_end_set_forward_dir:
	RETURN
; end of _set_forward_dir

_stop_both:

;test1.c,186 :: 		void stop_both()
;test1.c,188 :: 		PORTC &= (unsigned char)(~DIR_MASK);
	MOVLW      198
	ANDWF      PORTC+0, 1
;test1.c,189 :: 		CCPR1L = 0;
	CLRF       CCPR1L+0
;test1.c,190 :: 		CCPR2L = 0;
	CLRF       CCPR2L+0
;test1.c,191 :: 		}
L_end_stop_both:
	RETURN
; end of _stop_both

_stop_before_turn_obstacle:

;test1.c,194 :: 		void stop_before_turn_obstacle()
;test1.c,196 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,197 :: 		my_delay(STOP_BEFORE_TURN_MS);
	MOVLW      80
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,198 :: 		}
L_end_stop_before_turn_obstacle:
	RETURN
; end of _stop_before_turn_obstacle

_CCPPWM_init:

;test1.c,201 :: 		void CCPPWM_init(void)
;test1.c,203 :: 		CCP1CON = 0x0C;  // PWM mode
	MOVLW      12
	MOVWF      CCP1CON+0
;test1.c,204 :: 		CCP2CON = 0x0C;
	MOVLW      12
	MOVWF      CCP2CON+0
;test1.c,205 :: 		PR2 = 250;       // PWM period
	MOVLW      250
	MOVWF      PR2+0
;test1.c,206 :: 		CCPR1L = 125;
	MOVLW      125
	MOVWF      CCPR1L+0
;test1.c,207 :: 		CCPR2L = 125;
	MOVLW      125
	MOVWF      CCPR2L+0
;test1.c,208 :: 		T2CON  = 0x06;   // Timer2 ON, prescaler 1:16
	MOVLW      6
	MOVWF      T2CON+0
;test1.c,209 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_motor_L:

;test1.c,212 :: 		void motor_L(unsigned char speed){ CCPR1L = speed; }
	MOVF       FARG_motor_L_speed+0, 0
	MOVWF      CCPR1L+0
L_end_motor_L:
	RETURN
; end of _motor_L

_motor_R:

;test1.c,213 :: 		void motor_R(unsigned char speed){ CCPR2L = speed; }
	MOVF       FARG_motor_R_speed+0, 0
	MOVWF      CCPR2L+0
L_end_motor_R:
	RETURN
; end of _motor_R

_tmr1_read_16:

;test1.c,217 :: 		unsigned int tmr1_read_16(void)
;test1.c,219 :: 		unsigned char l = TMR1L;
	MOVF       TMR1L+0, 0
	MOVWF      R6+0
;test1.c,220 :: 		unsigned char h = TMR1H;
	MOVF       TMR1H+0, 0
	MOVWF      R7+0
;test1.c,221 :: 		return ((unsigned int)h << 8) | (unsigned int)l;
	MOVF       R7+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	MOVF       R4+0, 0
	MOVWF      R2+1
	CLRF       R2+0
	MOVF       R6+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R2+0, 0
	IORWF      R0+0, 1
	MOVF       R2+1, 0
	IORWF      R0+1, 1
;test1.c,222 :: 		}
L_end_tmr1_read_16:
	RETURN
; end of _tmr1_read_16

_my_delay_us:

;test1.c,224 :: 		void my_delay_us(unsigned int us_local)
;test1.c,229 :: 		T1CON &= (unsigned char)~0x01;
	MOVLW      254
	ANDWF      T1CON+0, 1
;test1.c,232 :: 		T1CON &= (unsigned char)~(0x02 | 0x30);
	MOVLW      205
	ANDWF      T1CON+0, 1
;test1.c,233 :: 		T1CON |= 0x10;
	BSF        T1CON+0, 4
;test1.c,236 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;test1.c,237 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;test1.c,240 :: 		T1CON |= 0x01;
	BSF        T1CON+0, 0
;test1.c,242 :: 		start = tmr1_read_16();
	CALL       _tmr1_read_16+0
	MOVF       R0+0, 0
	MOVWF      my_delay_us_start_L0+0
	MOVF       R0+1, 0
	MOVWF      my_delay_us_start_L0+1
;test1.c,243 :: 		while ((unsigned int)(tmr1_read_16() - start) < us_local) { }
L_my_delay_us5:
	CALL       _tmr1_read_16+0
	MOVF       my_delay_us_start_L0+0, 0
	SUBWF      R0+0, 0
	MOVWF      R2+0
	MOVF       my_delay_us_start_L0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      R0+1, 0
	MOVWF      R2+1
	MOVF       FARG_my_delay_us_us_local+1, 0
	SUBWF      R2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__my_delay_us140
	MOVF       FARG_my_delay_us_us_local+0, 0
	SUBWF      R2+0, 0
L__my_delay_us140:
	BTFSC      STATUS+0, 0
	GOTO       L_my_delay_us6
	GOTO       L_my_delay_us5
L_my_delay_us6:
;test1.c,246 :: 		T1CON &= (unsigned char)~0x01;
	MOVLW      254
	ANDWF      T1CON+0, 1
;test1.c,247 :: 		}
L_end_my_delay_us:
	RETURN
; end of _my_delay_us

_raise_servo_flag:

;test1.c,251 :: 		void raise_servo_flag(void)
;test1.c,253 :: 		unsigned int high_us = SERVO_HIGH_US;
	MOVLW      46
	MOVWF      raise_servo_flag_high_us_L0+0
	MOVLW      9
	MOVWF      raise_servo_flag_high_us_L0+1
;test1.c,255 :: 		for (servo_i = 0; servo_i < 100; servo_i++) {
	CLRF       _servo_i+0
	CLRF       _servo_i+1
L_raise_servo_flag7:
	MOVLW      0
	SUBWF      _servo_i+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__raise_servo_flag142
	MOVLW      100
	SUBWF      _servo_i+0, 0
L__raise_servo_flag142:
	BTFSC      STATUS+0, 0
	GOTO       L_raise_servo_flag8
;test1.c,256 :: 		PORTC |= SERVO_MASK;                         // HIGH pulse
	BSF        PORTC+0, 6
;test1.c,257 :: 		my_delay_us(high_us);
	MOVF       raise_servo_flag_high_us_L0+0, 0
	MOVWF      FARG_my_delay_us_us_local+0
	MOVF       raise_servo_flag_high_us_L0+1, 0
	MOVWF      FARG_my_delay_us_us_local+1
	CALL       _my_delay_us+0
;test1.c,258 :: 		PORTC &= (unsigned char)~SERVO_MASK;         // LOW rest of the frame
	MOVLW      191
	ANDWF      PORTC+0, 1
;test1.c,259 :: 		my_delay_us((unsigned int)(SERVO_FRAME_US - high_us));
	MOVF       raise_servo_flag_high_us_L0+0, 0
	SUBLW      32
	MOVWF      FARG_my_delay_us_us_local+0
	MOVF       raise_servo_flag_high_us_L0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      78
	MOVWF      FARG_my_delay_us_us_local+1
	CALL       _my_delay_us+0
;test1.c,255 :: 		for (servo_i = 0; servo_i < 100; servo_i++) {
	INCF       _servo_i+0, 1
	BTFSC      STATUS+0, 2
	INCF       _servo_i+1, 1
;test1.c,260 :: 		}
	GOTO       L_raise_servo_flag7
L_raise_servo_flag8:
;test1.c,261 :: 		}
L_end_raise_servo_flag:
	RETURN
; end of _raise_servo_flag

_ultrasonic_cm:

;test1.c,265 :: 		unsigned int ultrasonic_cm(void)
;test1.c,271 :: 		T1CON &= (unsigned char)~0x01;
	MOVLW      254
	ANDWF      T1CON+0, 1
;test1.c,272 :: 		T1CON &= (unsigned char)~(0x02 | 0x30);
	MOVLW      205
	ANDWF      T1CON+0, 1
;test1.c,273 :: 		T1CON |= 0x10;
	BSF        T1CON+0, 4
;test1.c,276 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;test1.c,277 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;test1.c,280 :: 		PORTB |= TRIG_MASK;
	BSF        PORTB+0, 6
;test1.c,281 :: 		my_delay_us(10);
	MOVLW      10
	MOVWF      FARG_my_delay_us_us_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_us_us_local+1
	CALL       _my_delay_us+0
;test1.c,282 :: 		PORTB &= (unsigned char)~TRIG_MASK;
	MOVLW      191
	ANDWF      PORTB+0, 1
;test1.c,285 :: 		timeout = 0;
	CLRF       ultrasonic_cm_timeout_L0+0
	CLRF       ultrasonic_cm_timeout_L0+1
;test1.c,286 :: 		while (!(PORTB & ECHO_MASK)) {
L_ultrasonic_cm10:
	BTFSC      PORTB+0, 7
	GOTO       L_ultrasonic_cm11
;test1.c,287 :: 		if (timeout++ > 30000) return 0xFFFF;
	MOVF       ultrasonic_cm_timeout_L0+0, 0
	MOVWF      R1+0
	MOVF       ultrasonic_cm_timeout_L0+1, 0
	MOVWF      R1+1
	INCF       ultrasonic_cm_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       ultrasonic_cm_timeout_L0+1, 1
	MOVF       R1+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_cm144
	MOVF       R1+0, 0
	SUBLW      48
L__ultrasonic_cm144:
	BTFSC      STATUS+0, 0
	GOTO       L_ultrasonic_cm12
	MOVLW      255
	MOVWF      R0+0
	MOVLW      255
	MOVWF      R0+1
	GOTO       L_end_ultrasonic_cm
L_ultrasonic_cm12:
;test1.c,288 :: 		}
	GOTO       L_ultrasonic_cm10
L_ultrasonic_cm11:
;test1.c,291 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;test1.c,292 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;test1.c,293 :: 		T1CON |= 0x01;
	BSF        T1CON+0, 0
;test1.c,295 :: 		timeout = 0;
	CLRF       ultrasonic_cm_timeout_L0+0
	CLRF       ultrasonic_cm_timeout_L0+1
;test1.c,296 :: 		while (PORTB & ECHO_MASK) {
L_ultrasonic_cm13:
	BTFSS      PORTB+0, 7
	GOTO       L_ultrasonic_cm14
;test1.c,297 :: 		if (timeout++ > 60000) break;
	MOVF       ultrasonic_cm_timeout_L0+0, 0
	MOVWF      R1+0
	MOVF       ultrasonic_cm_timeout_L0+1, 0
	MOVWF      R1+1
	INCF       ultrasonic_cm_timeout_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       ultrasonic_cm_timeout_L0+1, 1
	MOVF       R1+1, 0
	SUBLW      234
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_cm145
	MOVF       R1+0, 0
	SUBLW      96
L__ultrasonic_cm145:
	BTFSC      STATUS+0, 0
	GOTO       L_ultrasonic_cm15
	GOTO       L_ultrasonic_cm14
L_ultrasonic_cm15:
;test1.c,298 :: 		}
	GOTO       L_ultrasonic_cm13
L_ultrasonic_cm14:
;test1.c,300 :: 		T1CON &= (unsigned char)~0x01;
	MOVLW      254
	ANDWF      T1CON+0, 1
;test1.c,302 :: 		t = (((unsigned int)TMR1H << 8) | TMR1L);
	MOVF       TMR1H+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	MOVF       R3+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;test1.c,303 :: 		return (unsigned int)(t / 58);   // convert us -> cm
	MOVLW      58
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
;test1.c,304 :: 		}
L_end_ultrasonic_cm:
	RETURN
; end of _ultrasonic_cm

_ir_detect:

;test1.c,307 :: 		unsigned char ir_detect(unsigned char mask)
;test1.c,310 :: 		return ((PORTD & mask) == 0);    // active low module
	MOVF       FARG_ir_detect_mask+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
;test1.c,314 :: 		}
L_end_ir_detect:
	RETURN
; end of _ir_detect

_line_both_black_raw:

;test1.c,317 :: 		unsigned char line_both_black_raw()
;test1.c,319 :: 		unsigned char both = (unsigned char)(IR_L_MASK | IR_R_MASK);
	MOVLW      12
	MOVWF      line_both_black_raw_both_L0+0
;test1.c,320 :: 		return ((PORTD & both) == both);
	MOVF       line_both_black_raw_both_L0+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORWF      line_both_black_raw_both_L0+0, 0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
;test1.c,321 :: 		}
L_end_line_both_black_raw:
	RETURN
; end of _line_both_black_raw

_line_any_black_raw:

;test1.c,322 :: 		unsigned char line_any_black_raw()
;test1.c,324 :: 		return ((PORTD & (IR_L_MASK | IR_R_MASK)) != 0);
	MOVLW      12
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
;test1.c,325 :: 		}
L_end_line_any_black_raw:
	RETURN
; end of _line_any_black_raw

_do_line_follow:

;test1.c,329 :: 		void do_line_follow(unsigned char fwd, unsigned char fast, unsigned char slow)
;test1.c,331 :: 		unsigned char left  = (PORTD & IR_L_MASK) ? 0 : 1;
	BTFSS      PORTD+0, 3
	GOTO       L_do_line_follow16
	CLRF       ?FLOC___do_line_followT99+0
	GOTO       L_do_line_follow17
L_do_line_follow16:
	MOVLW      1
	MOVWF      ?FLOC___do_line_followT99+0
L_do_line_follow17:
	MOVF       ?FLOC___do_line_followT99+0, 0
	MOVWF      do_line_follow_left_L0+0
;test1.c,332 :: 		unsigned char right = (PORTD & IR_R_MASK) ? 0 : 1;
	BTFSS      PORTD+0, 2
	GOTO       L_do_line_follow18
	CLRF       ?FLOC___do_line_followT101+0
	GOTO       L_do_line_follow19
L_do_line_follow18:
	MOVLW      1
	MOVWF      ?FLOC___do_line_followT101+0
L_do_line_follow19:
	MOVF       ?FLOC___do_line_followT101+0, 0
	MOVWF      do_line_follow_right_L0+0
;test1.c,334 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,336 :: 		if (left==1 && right==1) {
	MOVF       do_line_follow_left_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow22
	MOVF       do_line_follow_right_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow22
L__do_line_follow112:
;test1.c,337 :: 		motor_L(fwd); motor_R(fwd);
	MOVF       FARG_do_line_follow_fwd+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_fwd+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,338 :: 		} else if (left==1 && right==0) {
	GOTO       L_do_line_follow23
L_do_line_follow22:
	MOVF       do_line_follow_left_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow26
	MOVF       do_line_follow_right_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow26
L__do_line_follow111:
;test1.c,339 :: 		motor_L(fast); motor_R(slow);
	MOVF       FARG_do_line_follow_fast+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_slow+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,340 :: 		} else if (left==0 && right==1) {
	GOTO       L_do_line_follow27
L_do_line_follow26:
	MOVF       do_line_follow_left_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow30
	MOVF       do_line_follow_right_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow30
L__do_line_follow110:
;test1.c,341 :: 		motor_L(slow); motor_R(fast);
	MOVF       FARG_do_line_follow_slow+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_fast+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,342 :: 		} else {
	GOTO       L_do_line_follow31
L_do_line_follow30:
;test1.c,344 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,345 :: 		my_delay(INTERSECT_PAUSE_MS);
	MOVLW      244
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      1
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,347 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,348 :: 		motor_L(0);
	CLRF       FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,349 :: 		motor_R(fast);
	MOVF       FARG_do_line_follow_fast+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,350 :: 		my_delay(INTERSECT_TURN_MS);
	MOVLW      94
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      1
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,351 :: 		}
L_do_line_follow31:
L_do_line_follow27:
L_do_line_follow23:
;test1.c,352 :: 		}
L_end_do_line_follow:
	RETURN
; end of _do_line_follow

_do_line_follow_no_intersection:

;test1.c,355 :: 		void do_line_follow_no_intersection(unsigned char fwd, unsigned char fast, unsigned char slow)
;test1.c,357 :: 		unsigned char left  = (PORTD & IR_L_MASK) ? 0 : 1;
	BTFSS      PORTD+0, 3
	GOTO       L_do_line_follow_no_intersection32
	CLRF       ?FLOC___do_line_follow_no_intersectionT112+0
	GOTO       L_do_line_follow_no_intersection33
L_do_line_follow_no_intersection32:
	MOVLW      1
	MOVWF      ?FLOC___do_line_follow_no_intersectionT112+0
L_do_line_follow_no_intersection33:
	MOVF       ?FLOC___do_line_follow_no_intersectionT112+0, 0
	MOVWF      do_line_follow_no_intersection_left_L0+0
;test1.c,358 :: 		unsigned char right = (PORTD & IR_R_MASK) ? 0 : 1;
	BTFSS      PORTD+0, 2
	GOTO       L_do_line_follow_no_intersection34
	CLRF       ?FLOC___do_line_follow_no_intersectionT114+0
	GOTO       L_do_line_follow_no_intersection35
L_do_line_follow_no_intersection34:
	MOVLW      1
	MOVWF      ?FLOC___do_line_follow_no_intersectionT114+0
L_do_line_follow_no_intersection35:
	MOVF       ?FLOC___do_line_follow_no_intersectionT114+0, 0
	MOVWF      do_line_follow_no_intersection_right_L0+0
;test1.c,360 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,362 :: 		if (left==1 && right==1) {
	MOVF       do_line_follow_no_intersection_left_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection38
	MOVF       do_line_follow_no_intersection_right_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection38
L__do_line_follow_no_intersection115:
;test1.c,363 :: 		motor_L(fwd); motor_R(fwd);
	MOVF       FARG_do_line_follow_no_intersection_fwd+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_no_intersection_fwd+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,364 :: 		} else if (left==1 && right==0) {
	GOTO       L_do_line_follow_no_intersection39
L_do_line_follow_no_intersection38:
	MOVF       do_line_follow_no_intersection_left_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection42
	MOVF       do_line_follow_no_intersection_right_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection42
L__do_line_follow_no_intersection114:
;test1.c,365 :: 		motor_L(fast); motor_R(slow);
	MOVF       FARG_do_line_follow_no_intersection_fast+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_no_intersection_slow+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,366 :: 		} else if (left==0 && right==1) {
	GOTO       L_do_line_follow_no_intersection43
L_do_line_follow_no_intersection42:
	MOVF       do_line_follow_no_intersection_left_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection46
	MOVF       do_line_follow_no_intersection_right_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_do_line_follow_no_intersection46
L__do_line_follow_no_intersection113:
;test1.c,367 :: 		motor_L(slow); motor_R(fast);
	MOVF       FARG_do_line_follow_no_intersection_slow+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
	MOVF       FARG_do_line_follow_no_intersection_fast+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,368 :: 		} else {
	GOTO       L_do_line_follow_no_intersection47
L_do_line_follow_no_intersection46:
;test1.c,369 :: 		motor_L(slow);
	MOVF       FARG_do_line_follow_no_intersection_slow+0, 0
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,370 :: 		motor_R(slow);
	MOVF       FARG_do_line_follow_no_intersection_slow+0, 0
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,371 :: 		}
L_do_line_follow_no_intersection47:
L_do_line_follow_no_intersection43:
L_do_line_follow_no_intersection39:
;test1.c,372 :: 		}
L_end_do_line_follow_no_intersection:
	RETURN
; end of _do_line_follow_no_intersection

_obs_forward:

;test1.c,375 :: 		void obs_forward()
;test1.c,377 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,378 :: 		motor_L(OBS_FWD);
	MOVLW      90
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,379 :: 		motor_R(OBS_FWD);
	MOVLW      90
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,380 :: 		}
L_end_obs_forward:
	RETURN
; end of _obs_forward

_obs_soft_left:

;test1.c,381 :: 		void obs_soft_left()
;test1.c,383 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,384 :: 		motor_L(OBS_SLOW);
	MOVLW      25
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,385 :: 		motor_R(OBS_FAST);
	MOVLW      110
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,386 :: 		my_delay(WALL_SOFT_TURN_MS);
	MOVLW      70
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,387 :: 		}
L_end_obs_soft_left:
	RETURN
; end of _obs_soft_left

_obs_soft_right:

;test1.c,388 :: 		void obs_soft_right()
;test1.c,390 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,391 :: 		motor_L(OBS_FAST);
	MOVLW      110
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,392 :: 		motor_R(OBS_SLOW);
	MOVLW      25
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,393 :: 		my_delay(WALL_SOFT_TURN_MS);
	MOVLW      70
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,394 :: 		}
L_end_obs_soft_right:
	RETURN
; end of _obs_soft_right

_obs_very_slight_left:

;test1.c,395 :: 		void obs_very_slight_left()
;test1.c,397 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,398 :: 		motor_L(OBS_SLOW);
	MOVLW      25
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,399 :: 		motor_R(OBS_FAST);
	MOVLW      110
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,400 :: 		my_delay(WALL_VERY_SLIGHT_MS);
	MOVLW      35
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,401 :: 		}
L_end_obs_very_slight_left:
	RETURN
; end of _obs_very_slight_left

_pivot_right_90:

;test1.c,404 :: 		void pivot_right_90()
;test1.c,406 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,407 :: 		motor_L(OBS_FAST);
	MOVLW      110
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,408 :: 		motor_R(0);
	CLRF       FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,409 :: 		my_delay(TURN_90_MS);
	MOVLW      128
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      2
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,410 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,411 :: 		my_delay(80);
	MOVLW      80
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,412 :: 		}
L_end_pivot_right_90:
	RETURN
; end of _pivot_right_90

_park_forward:

;test1.c,415 :: 		void park_forward()
;test1.c,417 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,418 :: 		motor_L(PARK_FWD);
	MOVLW      60
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,419 :: 		motor_R(PARK_FWD);
	MOVLW      60
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,420 :: 		}
L_end_park_forward:
	RETURN
; end of _park_forward

_park_creep_arc_right_pulse:

;test1.c,423 :: 		void park_creep_arc_right_pulse(void)
;test1.c,425 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,426 :: 		motor_L(PARK_ARC_LEFT_SPEED);
	MOVLW      73
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,427 :: 		motor_R(PARK_ARC_RIGHT_SPEED);
	MOVLW      45
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,428 :: 		my_delay(PARK_ARC_PULSE_MS);
	MOVLW      30
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,429 :: 		}
L_end_park_creep_arc_right_pulse:
	RETURN
; end of _park_creep_arc_right_pulse

_park_entry_sequence_once:

;test1.c,432 :: 		void park_entry_sequence_once(void)
;test1.c,434 :: 		set_forward_dir();
	CALL       _set_forward_dir+0
;test1.c,435 :: 		motor_L(PARK_FWD);
	MOVLW      60
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,436 :: 		motor_R(PARK_FWD);
	MOVLW      60
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,437 :: 		my_delay(PARK_ENTRY_FORWARD_MS);
	MOVLW      4
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      1
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,439 :: 		motor_L(PARK_FAST);
	MOVLW      70
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,440 :: 		motor_R(PARK_SLOW);
	MOVLW      40
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,441 :: 		my_delay(PARK_ENTRY_TURN_MS);
	MOVLW      124
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      1
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,443 :: 		motor_L(PARK_SLOW);
	MOVLW      40
	MOVWF      FARG_motor_L_speed+0
	CALL       _motor_L+0
;test1.c,444 :: 		motor_R(PARK_SLOW);
	MOVLW      40
	MOVWF      FARG_motor_R_speed+0
	CALL       _motor_R+0
;test1.c,445 :: 		my_delay(PARK_ENTRY_SETTLE_MS);
	MOVLW      60
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,446 :: 		}
L_end_park_entry_sequence_once:
	RETURN
; end of _park_entry_sequence_once

_main:

;test1.c,451 :: 		void main()
;test1.c,453 :: 		unsigned char running = 0;
	CLRF       main_running_L0+0
	CLRF       main_stage_L0+0
	CLRF       main_in_tunnel_L0+0
	CLRF       main_exit_count_L0+0
	CLRF       main_post_tunnel_init_done_L0+0
	CLRF       main_park_line_cnt_L0+0
	CLRF       main_park_line_cnt_L0+1
	CLRF       main_beep_start_L0+0
	CLRF       main_beep_start_L0+1
	CLRF       main_beep_start_L0+2
	CLRF       main_beep_start_L0+3
	CLRF       main_beep_off_at_L0+0
	CLRF       main_beep_off_at_L0+1
	CLRF       main_beep_off_at_L0+2
	CLRF       main_beep_off_at_L0+3
	CLRF       main_park_stop_stable_L0+0
	CLRF       main_did_park_entry_turn_L0+0
;test1.c,471 :: 		TRISA = 0x01;   // RA0 ADC input
	MOVLW      1
	MOVWF      TRISA+0
;test1.c,472 :: 		TRISB = 0x81;   // RB0 button, RB7 echo
	MOVLW      129
	MOVWF      TRISB+0
;test1.c,473 :: 		TRISC = 0x00;   // motors + servo
	CLRF       TRISC+0
;test1.c,474 :: 		TRISD = 0x0F;   // sensors on RD0..RD3, LED on RD4
	MOVLW      15
	MOVWF      TRISD+0
;test1.c,477 :: 		TRISB &= (unsigned char)~0x40;  // RB6 TRIG output
	MOVLW      191
	ANDWF      TRISB+0, 1
;test1.c,478 :: 		TRISB |= 0x80;                  // RB7 ECHO input
	BSF        TRISB+0, 7
;test1.c,480 :: 		PORTA=0; PORTB=0; PORTC=0; PORTD=0;
	CLRF       PORTA+0
	CLRF       PORTB+0
	CLRF       PORTC+0
	CLRF       PORTD+0
;test1.c,482 :: 		ADC_Init_Custom();
	CALL       _ADC_Init_Custom+0
;test1.c,483 :: 		CCPPWM_init();
	CALL       _CCPPWM_init+0
;test1.c,484 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,485 :: 		led_off();
	CALL       _led_off+0
;test1.c,486 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,489 :: 		PORTC &= (unsigned char)~SERVO_MASK;
	MOVLW      191
	ANDWF      PORTC+0, 1
;test1.c,491 :: 		my_delay_init();
	CALL       _my_delay_init+0
;test1.c,493 :: 		while(1)
L_main48:
;test1.c,496 :: 		if ((PORTB & START_MASK) == 0) {
	MOVLW      1
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main50
;test1.c,497 :: 		my_delay(40);
	MOVLW      40
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,498 :: 		if ((PORTB & START_MASK) == 0) {
	MOVLW      1
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main51
;test1.c,499 :: 		while ((PORTB & START_MASK) == 0) { }
L_main52:
	MOVLW      1
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main53
	GOTO       L_main52
L_main53:
;test1.c,500 :: 		my_delay(40);
	MOVLW      40
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,502 :: 		running = !running;
	MOVF       main_running_L0+0, 0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      main_running_L0+0
;test1.c,504 :: 		if (running) {
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main54
;test1.c,505 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,506 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,507 :: 		led_off();
	CALL       _led_off+0
;test1.c,510 :: 		stage = STAGE_LINE;
	CLRF       main_stage_L0+0
;test1.c,511 :: 		in_tunnel = 0;
	CLRF       main_in_tunnel_L0+0
;test1.c,512 :: 		exit_count = 0;
	CLRF       main_exit_count_L0+0
;test1.c,513 :: 		post_tunnel_init_done = 0;
	CLRF       main_post_tunnel_init_done_L0+0
;test1.c,514 :: 		park_line_cnt = 0;
	CLRF       main_park_line_cnt_L0+0
	CLRF       main_park_line_cnt_L0+1
;test1.c,516 :: 		beep_start = ms_ticks;
	MOVF       _ms_ticks+0, 0
	MOVWF      main_beep_start_L0+0
	MOVF       _ms_ticks+1, 0
	MOVWF      main_beep_start_L0+1
	MOVF       _ms_ticks+2, 0
	MOVWF      main_beep_start_L0+2
	MOVF       _ms_ticks+3, 0
	MOVWF      main_beep_start_L0+3
;test1.c,517 :: 		beep_off_at = 0;
	CLRF       main_beep_off_at_L0+0
	CLRF       main_beep_off_at_L0+1
	CLRF       main_beep_off_at_L0+2
	CLRF       main_beep_off_at_L0+3
;test1.c,519 :: 		park_stop_stable = 0;
	CLRF       main_park_stop_stable_L0+0
;test1.c,520 :: 		did_park_entry_turn = 0;
	CLRF       main_did_park_entry_turn_L0+0
;test1.c,523 :: 		my_delay(START_DELAY_MS);
	MOVLW      184
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      11
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,524 :: 		led_on();
	CALL       _led_on+0
;test1.c,525 :: 		} else {
	GOTO       L_main55
L_main54:
;test1.c,526 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,527 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,528 :: 		led_off();
	CALL       _led_off+0
;test1.c,529 :: 		}
L_main55:
;test1.c,530 :: 		}
L_main51:
;test1.c,531 :: 		}
L_main50:
;test1.c,533 :: 		if (!running) { stop_both(); buz_off(); continue; }
	MOVF       main_running_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main56
	CALL       _stop_both+0
	CALL       _buz_off+0
	GOTO       L_main48
L_main56:
;test1.c,536 :: 		stage = STAGE_LINE;
	CLRF       main_stage_L0+0
;test1.c,537 :: 		while(1){
L_main57:
;test1.c,538 :: 		ldr = read_adc();
	CALL       _read_adc+0
;test1.c,539 :: 		in_tunnel = (ldr > LDR_DARK_TH) ? 1 : 0;
	MOVF       R0+1, 0
	SUBLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__main160
	MOVF       R0+0, 0
	SUBLW      194
L__main160:
	BTFSC      STATUS+0, 0
	GOTO       L_main59
	MOVLW      1
	MOVWF      ?FLOC___mainT140+0
	GOTO       L_main60
L_main59:
	CLRF       ?FLOC___mainT140+0
L_main60:
	MOVF       ?FLOC___mainT140+0, 0
	MOVWF      main_in_tunnel_L0+0
;test1.c,540 :: 		if (in_tunnel) { stage = STAGE_TUNNEL; break; }
	MOVF       ?FLOC___mainT140+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main61
	MOVLW      1
	MOVWF      main_stage_L0+0
	GOTO       L_main58
L_main61:
;test1.c,542 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,543 :: 		do_line_follow(SPD_FWD, SPD_FAST, SPD_SLOW);
	MOVLW      90
	MOVWF      FARG_do_line_follow_fwd+0
	MOVLW      110
	MOVWF      FARG_do_line_follow_fast+0
	MOVLW      10
	MOVWF      FARG_do_line_follow_slow+0
	CALL       _do_line_follow+0
;test1.c,544 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,545 :: 		}
	GOTO       L_main57
L_main58:
;test1.c,549 :: 		exit_count = 0;
	CLRF       main_exit_count_L0+0
;test1.c,550 :: 		while(1){
L_main62:
;test1.c,551 :: 		ldr = read_adc();
	CALL       _read_adc+0
;test1.c,552 :: 		in_tunnel = (ldr > LDR_DARK_TH) ? 1 : 0;
	MOVF       R0+1, 0
	SUBLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__main161
	MOVF       R0+0, 0
	SUBLW      194
L__main161:
	BTFSC      STATUS+0, 0
	GOTO       L_main64
	MOVLW      1
	MOVWF      ?FLOC___mainT142+0
	GOTO       L_main65
L_main64:
	CLRF       ?FLOC___mainT142+0
L_main65:
	MOVF       ?FLOC___mainT142+0, 0
	MOVWF      main_in_tunnel_L0+0
;test1.c,554 :: 		buz_on();
	CALL       _buz_on+0
;test1.c,555 :: 		do_line_follow(TUN_FWD, TUN_FAST, TUN_SLOW);
	MOVLW      140
	MOVWF      FARG_do_line_follow_fwd+0
	MOVLW      200
	MOVWF      FARG_do_line_follow_fast+0
	MOVLW      30
	MOVWF      FARG_do_line_follow_slow+0
	CALL       _do_line_follow+0
;test1.c,558 :: 		if (!in_tunnel) {
	MOVF       main_in_tunnel_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main66
;test1.c,559 :: 		if (exit_count < 255) exit_count++;
	MOVLW      255
	SUBWF      main_exit_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main67
	INCF       main_exit_count_L0+0, 1
L_main67:
;test1.c,560 :: 		if (exit_count >= TUNNEL_EXIT_STABLE_COUNT) { stage = STAGE_OBSTACLE; break; }
	MOVLW      40
	SUBWF      main_exit_count_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main68
	MOVLW      2
	MOVWF      main_stage_L0+0
	GOTO       L_main63
L_main68:
;test1.c,561 :: 		} else {
	GOTO       L_main69
L_main66:
;test1.c,562 :: 		exit_count = 0;
	CLRF       main_exit_count_L0+0
;test1.c,563 :: 		}
L_main69:
;test1.c,565 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,566 :: 		}
	GOTO       L_main62
L_main63:
;test1.c,567 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,570 :: 		post_tunnel_init_done = 0;
	CLRF       main_post_tunnel_init_done_L0+0
;test1.c,571 :: 		while(1){
L_main70:
;test1.c,574 :: 		if (line_any_black_raw()) {
	CALL       _line_any_black_raw+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main72
;test1.c,575 :: 		stage = STAGE_LINE_BOOST;
	MOVLW      3
	MOVWF      main_stage_L0+0
;test1.c,576 :: 		park_line_cnt = 0;
	CLRF       main_park_line_cnt_L0+0
	CLRF       main_park_line_cnt_L0+1
;test1.c,577 :: 		break;
	GOTO       L_main71
;test1.c,578 :: 		}
L_main72:
;test1.c,581 :: 		if (!post_tunnel_init_done) {
	MOVF       main_post_tunnel_init_done_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main73
;test1.c,582 :: 		stop_before_turn_obstacle();
	CALL       _stop_before_turn_obstacle+0
;test1.c,583 :: 		pivot_right_90();
	CALL       _pivot_right_90+0
;test1.c,585 :: 		while (!ir_detect(OBS_HI_MASK)) {
L_main74:
	MOVLW      2
	MOVWF      FARG_ir_detect_mask+0
	CALL       _ir_detect+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main75
;test1.c,586 :: 		dist = ultrasonic_cm();
	CALL       _ultrasonic_cm+0
	MOVF       R0+0, 0
	MOVWF      main_dist_L0+0
	MOVF       R0+1, 0
	MOVWF      main_dist_L0+1
;test1.c,587 :: 		if ((dist != 0xFFFF) && (dist < US_THRESH_CM)) {
	MOVF       R0+1, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L__main162
	MOVLW      255
	XORWF      R0+0, 0
L__main162:
	BTFSC      STATUS+0, 2
	GOTO       L_main78
	MOVLW      0
	SUBWF      main_dist_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main163
	MOVLW      20
	SUBWF      main_dist_L0+0, 0
L__main163:
	BTFSC      STATUS+0, 0
	GOTO       L_main78
L__main119:
;test1.c,588 :: 		stop_before_turn_obstacle();
	CALL       _stop_before_turn_obstacle+0
;test1.c,589 :: 		obs_soft_left();
	CALL       _obs_soft_left+0
;test1.c,590 :: 		} else {
	GOTO       L_main79
L_main78:
;test1.c,591 :: 		obs_forward();
	CALL       _obs_forward+0
;test1.c,592 :: 		}
L_main79:
;test1.c,593 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,594 :: 		}
	GOTO       L_main74
L_main75:
;test1.c,596 :: 		post_tunnel_init_done = 1;
	MOVLW      1
	MOVWF      main_post_tunnel_init_done_L0+0
;test1.c,597 :: 		my_delay(50);
	MOVLW      50
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,598 :: 		continue;
	GOTO       L_main70
;test1.c,599 :: 		}
L_main73:
;test1.c,603 :: 		unsigned char low  = ir_detect(OBS_LO_MASK);
	MOVLW      1
	MOVWF      FARG_ir_detect_mask+0
	CALL       _ir_detect+0
	MOVF       R0+0, 0
	MOVWF      main_low_L3+0
;test1.c,604 :: 		unsigned char high = ir_detect(OBS_HI_MASK);
	MOVLW      2
	MOVWF      FARG_ir_detect_mask+0
	CALL       _ir_detect+0
	MOVF       R0+0, 0
	MOVWF      main_high_L3+0
;test1.c,606 :: 		dist = ultrasonic_cm();
	CALL       _ultrasonic_cm+0
	MOVF       R0+0, 0
	MOVWF      main_dist_L0+0
	MOVF       R0+1, 0
	MOVWF      main_dist_L0+1
;test1.c,608 :: 		if ((dist != 0xFFFF) && (dist < US_THRESH_CM)) {
	MOVF       R0+1, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L__main164
	MOVLW      255
	XORWF      R0+0, 0
L__main164:
	BTFSC      STATUS+0, 2
	GOTO       L_main82
	MOVLW      0
	SUBWF      main_dist_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main165
	MOVLW      20
	SUBWF      main_dist_L0+0, 0
L__main165:
	BTFSC      STATUS+0, 0
	GOTO       L_main82
L__main118:
;test1.c,609 :: 		stop_before_turn_obstacle();
	CALL       _stop_before_turn_obstacle+0
;test1.c,610 :: 		obs_soft_left();
	CALL       _obs_soft_left+0
;test1.c,611 :: 		}
	GOTO       L_main83
L_main82:
;test1.c,612 :: 		else if (low) {
	MOVF       main_low_L3+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main84
;test1.c,613 :: 		stop_before_turn_obstacle();
	CALL       _stop_before_turn_obstacle+0
;test1.c,614 :: 		obs_very_slight_left();
	CALL       _obs_very_slight_left+0
;test1.c,615 :: 		}
	GOTO       L_main85
L_main84:
;test1.c,616 :: 		else if (high) {
	MOVF       main_high_L3+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main86
;test1.c,617 :: 		obs_forward();
	CALL       _obs_forward+0
;test1.c,618 :: 		}
	GOTO       L_main87
L_main86:
;test1.c,620 :: 		stop_before_turn_obstacle();
	CALL       _stop_before_turn_obstacle+0
;test1.c,621 :: 		obs_soft_right();
	CALL       _obs_soft_right+0
;test1.c,622 :: 		}
L_main87:
L_main85:
L_main83:
;test1.c,625 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,626 :: 		}
	GOTO       L_main70
L_main71:
;test1.c,629 :: 		while(stage == STAGE_LINE_BOOST){
L_main88:
	MOVF       main_stage_L0+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main89
;test1.c,631 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,634 :: 		if (line_both_black_raw()) {
	CALL       _line_both_black_raw+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main90
;test1.c,635 :: 		if (park_line_cnt < 60000) park_line_cnt++;
	MOVLW      234
	SUBWF      main_park_line_cnt_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main166
	MOVLW      96
	SUBWF      main_park_line_cnt_L0+0, 0
L__main166:
	BTFSC      STATUS+0, 0
	GOTO       L_main91
	INCF       main_park_line_cnt_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_park_line_cnt_L0+1, 1
L_main91:
;test1.c,636 :: 		} else {
	GOTO       L_main92
L_main90:
;test1.c,637 :: 		if (park_line_cnt > 0) park_line_cnt--;
	MOVF       main_park_line_cnt_L0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main167
	MOVF       main_park_line_cnt_L0+0, 0
	SUBLW      0
L__main167:
	BTFSC      STATUS+0, 0
	GOTO       L_main93
	MOVLW      1
	SUBWF      main_park_line_cnt_L0+0, 1
	BTFSS      STATUS+0, 0
	DECF       main_park_line_cnt_L0+1, 1
L_main93:
;test1.c,638 :: 		}
L_main92:
;test1.c,640 :: 		if (park_line_cnt >= PARK_LINE_COUNT) {
	MOVLW      0
	SUBWF      main_park_line_cnt_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main168
	MOVLW      40
	SUBWF      main_park_line_cnt_L0+0, 0
L__main168:
	BTFSS      STATUS+0, 0
	GOTO       L_main94
;test1.c,641 :: 		stage = STAGE_PARKING;
	MOVLW      4
	MOVWF      main_stage_L0+0
;test1.c,642 :: 		park_line_cnt = 0;
	CLRF       main_park_line_cnt_L0+0
	CLRF       main_park_line_cnt_L0+1
;test1.c,645 :: 		beep_start = ms_ticks;
	MOVF       _ms_ticks+0, 0
	MOVWF      main_beep_start_L0+0
	MOVF       _ms_ticks+1, 0
	MOVWF      main_beep_start_L0+1
	MOVF       _ms_ticks+2, 0
	MOVWF      main_beep_start_L0+2
	MOVF       _ms_ticks+3, 0
	MOVWF      main_beep_start_L0+3
;test1.c,646 :: 		beep_off_at = 0;
	CLRF       main_beep_off_at_L0+0
	CLRF       main_beep_off_at_L0+1
	CLRF       main_beep_off_at_L0+2
	CLRF       main_beep_off_at_L0+3
;test1.c,647 :: 		park_stop_stable = 0;
	CLRF       main_park_stop_stable_L0+0
;test1.c,648 :: 		did_park_entry_turn = 0;
	CLRF       main_did_park_entry_turn_L0+0
;test1.c,650 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,651 :: 		break;
	GOTO       L_main89
;test1.c,652 :: 		}
L_main94:
;test1.c,654 :: 		do_line_follow_no_intersection(SPD_FWD_B, SPD_FAST_B, SPD_SLOW_B);
	MOVLW      110
	MOVWF      FARG_do_line_follow_no_intersection_fwd+0
	MOVLW      150
	MOVWF      FARG_do_line_follow_no_intersection_fast+0
	MOVLW      35
	MOVWF      FARG_do_line_follow_no_intersection_slow+0
	CALL       _do_line_follow_no_intersection+0
;test1.c,655 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,656 :: 		}
	GOTO       L_main88
L_main89:
;test1.c,659 :: 		while(stage == STAGE_PARKING){
L_main95:
	MOVF       main_stage_L0+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main96
;test1.c,662 :: 		if (!did_park_entry_turn) {
	MOVF       main_did_park_entry_turn_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main97
;test1.c,663 :: 		did_park_entry_turn = 1;
	MOVLW      1
	MOVWF      main_did_park_entry_turn_L0+0
;test1.c,664 :: 		park_entry_sequence_once();
	CALL       _park_entry_sequence_once+0
;test1.c,665 :: 		}
L_main97:
;test1.c,668 :: 		if ((unsigned long)(ms_ticks - beep_start) >= (unsigned long)BEEP_PERIOD_MS) {
	MOVF       _ms_ticks+0, 0
	MOVWF      R1+0
	MOVF       _ms_ticks+1, 0
	MOVWF      R1+1
	MOVF       _ms_ticks+2, 0
	MOVWF      R1+2
	MOVF       _ms_ticks+3, 0
	MOVWF      R1+3
	MOVF       main_beep_start_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_beep_start_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_beep_start_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_beep_start_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_beep_start_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_beep_start_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_beep_start_L0+3, 0
	SUBWF      R1+3, 1
	MOVLW      0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main169
	MOVLW      0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main169
	MOVLW      3
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main169
	MOVLW      232
	SUBWF      R1+0, 0
L__main169:
	BTFSS      STATUS+0, 0
	GOTO       L_main98
;test1.c,669 :: 		beep_start = ms_ticks;
	MOVF       _ms_ticks+0, 0
	MOVWF      main_beep_start_L0+0
	MOVF       _ms_ticks+1, 0
	MOVWF      main_beep_start_L0+1
	MOVF       _ms_ticks+2, 0
	MOVWF      main_beep_start_L0+2
	MOVF       _ms_ticks+3, 0
	MOVWF      main_beep_start_L0+3
;test1.c,670 :: 		buz_on();
	CALL       _buz_on+0
;test1.c,671 :: 		beep_off_at = ms_ticks + (unsigned long)BEEP_ON_MS;
	MOVLW      120
	MOVWF      main_beep_off_at_L0+0
	MOVLW      0
	MOVWF      main_beep_off_at_L0+1
	MOVLW      0
	MOVWF      main_beep_off_at_L0+2
	MOVLW      0
	MOVWF      main_beep_off_at_L0+3
	MOVF       _ms_ticks+0, 0
	ADDWF      main_beep_off_at_L0+0, 1
	MOVF       _ms_ticks+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ms_ticks+1, 0
	ADDWF      main_beep_off_at_L0+1, 1
	MOVF       _ms_ticks+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ms_ticks+2, 0
	ADDWF      main_beep_off_at_L0+2, 1
	MOVF       _ms_ticks+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ms_ticks+3, 0
	ADDWF      main_beep_off_at_L0+3, 1
;test1.c,672 :: 		}
L_main98:
;test1.c,673 :: 		if (beep_off_at != 0 && (unsigned long)(ms_ticks) >= beep_off_at) {
	MOVLW      0
	MOVWF      R0+0
	XORWF      main_beep_off_at_L0+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main170
	MOVF       R0+0, 0
	XORWF      main_beep_off_at_L0+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main170
	MOVF       R0+0, 0
	XORWF      main_beep_off_at_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main170
	MOVF       main_beep_off_at_L0+0, 0
	XORLW      0
L__main170:
	BTFSC      STATUS+0, 2
	GOTO       L_main101
	MOVF       _ms_ticks+0, 0
	MOVWF      R1+0
	MOVF       _ms_ticks+1, 0
	MOVWF      R1+1
	MOVF       _ms_ticks+2, 0
	MOVWF      R1+2
	MOVF       _ms_ticks+3, 0
	MOVWF      R1+3
	MOVF       main_beep_off_at_L0+3, 0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main171
	MOVF       main_beep_off_at_L0+2, 0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main171
	MOVF       main_beep_off_at_L0+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main171
	MOVF       main_beep_off_at_L0+0, 0
	SUBWF      R1+0, 0
L__main171:
	BTFSS      STATUS+0, 0
	GOTO       L_main101
L__main117:
;test1.c,674 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,675 :: 		beep_off_at = 0;
	CLRF       main_beep_off_at_L0+0
	CLRF       main_beep_off_at_L0+1
	CLRF       main_beep_off_at_L0+2
	CLRF       main_beep_off_at_L0+3
;test1.c,676 :: 		}
L_main101:
;test1.c,679 :: 		dist = ultrasonic_cm();
	CALL       _ultrasonic_cm+0
	MOVF       R0+0, 0
	MOVWF      main_dist_L0+0
	MOVF       R0+1, 0
	MOVWF      main_dist_L0+1
;test1.c,680 :: 		if ((dist != 0xFFFF) && (dist <= PARK_STOP_CM)) {
	MOVF       R0+1, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L__main172
	MOVLW      255
	XORWF      R0+0, 0
L__main172:
	BTFSC      STATUS+0, 2
	GOTO       L_main104
	MOVF       main_dist_L0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main173
	MOVF       main_dist_L0+0, 0
	SUBLW      13
L__main173:
	BTFSS      STATUS+0, 0
	GOTO       L_main104
L__main116:
;test1.c,681 :: 		if (park_stop_stable < 10) park_stop_stable++;
	MOVLW      10
	SUBWF      main_park_stop_stable_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main105
	INCF       main_park_stop_stable_L0+0, 1
L_main105:
;test1.c,682 :: 		} else {
	GOTO       L_main106
L_main104:
;test1.c,683 :: 		park_stop_stable = 0;
	CLRF       main_park_stop_stable_L0+0
;test1.c,684 :: 		}
L_main106:
;test1.c,687 :: 		if (park_stop_stable >= 10) {
	MOVLW      10
	SUBWF      main_park_stop_stable_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main107
;test1.c,688 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,689 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,690 :: 		led_off();
	CALL       _led_off+0
;test1.c,692 :: 		raise_servo_flag();
	CALL       _raise_servo_flag+0
;test1.c,694 :: 		stage = STAGE_DONE;
	MOVLW      5
	MOVWF      main_stage_L0+0
;test1.c,695 :: 		break;
	GOTO       L_main96
;test1.c,696 :: 		}
L_main107:
;test1.c,699 :: 		park_creep_arc_right_pulse();
	CALL       _park_creep_arc_right_pulse+0
;test1.c,701 :: 		my_delay(5);
	MOVLW      5
	MOVWF      FARG_my_delay_ms_local+0
	MOVLW      0
	MOVWF      FARG_my_delay_ms_local+1
	CALL       _my_delay+0
;test1.c,702 :: 		}
	GOTO       L_main95
L_main96:
;test1.c,706 :: 		while(stage == STAGE_DONE){
L_main108:
	MOVF       main_stage_L0+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_main109
;test1.c,707 :: 		stop_both();
	CALL       _stop_both+0
;test1.c,708 :: 		buz_off();
	CALL       _buz_off+0
;test1.c,709 :: 		led_off();
	CALL       _led_off+0
;test1.c,710 :: 		PORTC &= (unsigned char)~SERVO_MASK;
	MOVLW      191
	ANDWF      PORTC+0, 1
;test1.c,711 :: 		}
	GOTO       L_main108
L_main109:
;test1.c,712 :: 		}
	GOTO       L_main48
;test1.c,713 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
