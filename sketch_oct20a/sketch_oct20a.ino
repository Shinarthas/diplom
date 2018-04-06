int val; // Задаем переменную val для отслеживания нажатия клавиши
int ledpin = 13; // задаем цифровой интерфейс ввода/вывода 13 - это наш светодиод
int analogPin = A0;
volatile unsigned long int timerLED1;

ISR (TIMER0_COMPA_vact){ // функция вызываемая таймером T0
  timerLED1++;
  Serial.println(timerLED1);

}
void setup ()
{
  //timerLED1=0;
  Serial.begin (9600); // Задаем скорость обмена com-порта 9600
  pinMode (ledpin, OUTPUT); // Задаем ledpin = 13 как интерфейс вывода информации


  TCCR0A |= (1<<WGM01); // сброс при совпадении
  OCR0A   = 0xF9;       // начало отсчета до переопределения 249
  TIMSK0 |= (1<<OCIE0A);// разрештить прерывание при совпадении с регистро А
  TCCR0B |=(1<<CS01)|(1<<CS00);// установить делитель частоты на 64
  sei();
}

void loop ()
{
  /*
int rawReading = analogRead(analogPin);
float volts = rawReading;
  Serial.println(volts);
  if(rawReading>100){
    digitalWrite (ledpin, HIGH); 
  }else{
    digitalWrite (ledpin, LOW); 
  }
delay(2);
*/
}

