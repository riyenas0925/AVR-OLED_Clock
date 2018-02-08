// CodeVisionAVR C Compiler
// (C) 1998-2004 Pavel Haiduc, HP InfoTech S.R.L.
// I/O registers definitions for the ATmega8
#pragma used+
sfrb TWBR=0;
sfrb TWSR=1;
sfrb TWAR=2;
sfrb TWDR=3;
sfrb ADCL=4;
sfrb ADCH=5;
sfrw ADCW=4;      // 16 bit access
sfrb ADCSRA=6;
sfrb ADMUX=7;
sfrb ACSR=8;
sfrb UBRRL=9;
sfrb UCSRB=0xa;
sfrb UCSRA=0xb;
sfrb UDR=0xc;
sfrb SPCR=0xd;
sfrb SPSR=0xe;
sfrb SPDR=0xf;
sfrb PIND=0x10;
sfrb DDRD=0x11;
sfrb PORTD=0x12;
sfrb PINC=0x13;
sfrb DDRC=0x14;
sfrb PORTC=0x15;
sfrb PINB=0x16;
sfrb DDRB=0x17;
sfrb PORTB=0x18;
sfrb EECR=0x1c;
sfrb EEDR=0x1d;
sfrb EEARL=0x1e;
sfrb EEARH=0x1f;
sfrw EEAR=0x1e;   // 16 bit access
sfrb UBRRH=0x20;
sfrb UCSRC=0X20;
sfrb WDTCR=0x21;
sfrb ASSR=0x22;
sfrb OCR2=0x23;
sfrb TCNT2=0x24;
sfrb TCCR2=0x25;
sfrb ICR1L=0x26;
sfrb ICR1H=0x27;
sfrw ICR1=0x26;   // 16 bit access
sfrb OCR1BL=0x28;
sfrb OCR1BH=0x29;
sfrw OCR1B=0x28;  // 16 bit access
sfrb OCR1AL=0x2a;
sfrb OCR1AH=0x2b;
sfrw OCR1A=0x2a;  // 16 bit access
sfrb TCNT1L=0x2c;
sfrb TCNT1H=0x2d;
sfrw TCNT1=0x2c;  // 16 bit access
sfrb TCCR1B=0x2e;
sfrb TCCR1A=0x2f;
sfrb SFIOR=0x30;
sfrb OSCCAL=0x31;
sfrb TCNT0=0x32;
sfrb TCCR0=0x33;
sfrb MCUCSR=0x34;
sfrb MCUCR=0x35;
sfrb TWCR=0x36;
sfrb SPMCR=0x37;
sfrb TIFR=0x38;
sfrb TIMSK=0x39;
sfrb GIFR=0x3a;
sfrb GICR=0x3b;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-
// Interrupt vectors definitions
// CodeVisionAVR C Compiler
// (C) 1998-2000 Pavel Haiduc, HP InfoTech S.R.L.
#pragma used+
void delay_us(unsigned int n);
void delay_ms(unsigned int n);
#pragma used-
// CodeVisionAVR C Compiler
// (C) 1998-2003 Pavel Haiduc, HP InfoTech S.R.L.
// Prototypes for standard I/O functions
// CodeVisionAVR C Compiler
// (C) 1998-2002 Pavel Haiduc, HP InfoTech S.R.L.
// Variable length argument list macros
typedef char *va_list;
#pragma used+
char getchar(void);
void putchar(char c);
void puts(char *str);
void putsf(char flash *str);
char *gets(char *str,unsigned int len);
void printf(char flash *fmtstr,...);
void sprintf(char *str, char flash *fmtstr,...);
void vprintf (char flash * fmtstr, va_list argptr);
void vsprintf (char *str, char flash * fmtstr, va_list argptr);
signed char scanf(char flash *fmtstr,...);
signed char sscanf(char *str, char flash *fmtstr,...);
                                               #pragma used-
#pragma library stdio.lib
unsigned char sec_1, sec_10, min_1, min_10, hour_1, hour_10;
unsigned char time_data[3];
void digit_num(unsigned char *ch);
void RTC_init(void);
void RTC_read(void);
void USART_init(void);
void tx_out(unsigned char data);
void set_time(void);
void USART_init(void)
{                 
        UCSRB=(1<<3);	//TX Enable
	UCSRC=0x86;
	UBRRH=103 >> 8;
	UBRRL=103;	//Baud 115200으로 설정
}
void tx_out(unsigned char data)
{
	while(!(UCSRA&(1<<5)));
	UDR=data;
}
//각자리수값 구하는 함수
void digit_num(unsigned char *ch)
{
	sec_1 = ch[0]&0x0F;
	sec_10 = (ch[0]&0xF0) >> 4;
	min_1 = ch[1]&0x0F;
	min_10 = (ch[1]&0xF0) >> 4;
	hour_1 = ch[2]&0x0F;
	hour_10 = (ch[2]&0xF0) >> 4;
}
void RTC_read(void)
{
	TWCR=0xA4;    //Send START
	while (!(TWCR & (1<<7)));
	TWDR=0xD0;    //slave address + W
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
	TWDR=0x00;    //
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
	TWCR=0x94;    //Send STOP
	TWCR=0xA4;    //Send START
	while (!(TWCR & (1<<7)));
	TWDR=0xD1;    //slave address + R
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
	TWCR=0xC4;
	while (!(TWCR & (1<<7)));
	time_data[0]=TWDR;   //sec
		TWCR=0xC4;
	while (!(TWCR & (1<<7)));
	time_data[1]=TWDR;   //min
		TWCR=0x84;
	while (!(TWCR & (1<<7)));
	time_data[2]=TWDR;   //hour
	TWCR=0x94;    //Send STOP
}
void set_time(void)
{
	TWCR=0xA4;	//Send START
	while (!(TWCR & (1<<7)));
	TWDR=0xD0;	//slave address + R/W
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWDR=0x00;	//data 모드
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
	TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
	TWCR=0x94;	//Send STOP
}
void RTC_init(void)
{
	TWCR=0xA4;    //Send START
	while (!(TWCR & (1<<7)));
	TWDR=0xD0;    //slave address + R/W
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWDR=0x07;    //control register
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWDR=0x00;    //1Hz로 설정
	TWCR=0x84;
	while (!(TWCR & (1<<7)));
		TWCR=0x94;    //Send STOP
}
void main(void)
{
        DDRC = 0xFF;
        DDRD = 0XFF;
                TWBR = 72;
        TWSR = 0x00;
        USART_init();
                RTC_init();
        set_time();
        delay_ms(50);
        while (1)
        {
                RTC_read();
                                digit_num(time_data);
                                          tx_out(hour_10);
                tx_out(hour_1);
                                tx_out(min_10);
                tx_out(min_1);
                                tx_out(sec_10);
                tx_out(sec_1);
                delay_ms(1000);
      };
}
