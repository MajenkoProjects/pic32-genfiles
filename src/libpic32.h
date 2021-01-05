#if defined(__cplusplus)
extern "C" {
#endif

void reverse(char* begin, char* end);
char* ltoa(long value, char* result, int base);
char* ultoa(unsigned long value, char* result, int base);
char * dtostrf(double number, signed char width, unsigned char prec, char *s);

#if defined(__cplusplus)
}
#endif
