
main() {
  int temp;
  float celsius;

    putchar('\n');
    printf("Input a temperature in Farenheit:");
    scanf("%d", &temp);
    celsius = (5.0 / 9.0) * (temp - 32);
    printf("%d degrees F is %6.2f degrees celsius\n",temp, celsius);
    putchar('\n');
}

