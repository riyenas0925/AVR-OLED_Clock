#include <mega8.h>
#include <delay.h>
#include <stdio.h>

#define UDRE 5
#define TWINT 7
#define TXEN 3
#define RXEN 4

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
        UCSRB=(1<<TXEN);	//TX Enable
	UCSRC=0x86;
	UBRRH=103 >> 8;
	UBRRL=103;	//Baud 115200으로 설정
}

void tx_out(unsigned char data)
{
	while(!(UCSRA&(1<<UDRE)));
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
	while (!(TWCR & (1<<TWINT)));

	TWDR=0xD0;    //slave address + W
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));

	TWDR=0x00;    //
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));

	TWCR=0x94;    //Send STOP


	TWCR=0xA4;    //Send START
	while (!(TWCR & (1<<TWINT)));

	TWDR=0xD1;    //slave address + R
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));

	TWCR=0xC4;
	while (!(TWCR & (1<<TWINT)));
	time_data[0]=TWDR;   //sec
	
	TWCR=0xC4;
	while (!(TWCR & (1<<TWINT)));
	time_data[1]=TWDR;   //min
	
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	time_data[2]=TWDR;   //hour

	TWCR=0x94;    //Send STOP
}

void set_time(void)
{
	TWCR=0xA4;	//Send START
	while (!(TWCR & (1<<TWINT)));

	TWDR=0xD0;	//slave address + R/W
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
	TWDR=0x00;	//data 모드
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));

	TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
	TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
	TWDR=0x00;	//data 출력
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));

	TWCR=0x94;	//Send STOP
}

void RTC_init(void)
{
	TWCR=0xA4;    //Send START
	while (!(TWCR & (1<<TWINT)));

	TWDR=0xD0;    //slave address + R/W
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
	TWDR=0x07;    //control register
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
	TWDR=0x00;    //1Hz로 설정
	TWCR=0x84;
	while (!(TWCR & (1<<TWINT)));
	
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
