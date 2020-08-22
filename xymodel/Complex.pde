
class Complex {
    float re;   // the re part
    float im;   // the imaginary part

    public Complex(float re, float im) {
        this.re = re;
        this.im = im;
    }
    public Complex(float re) {
      this.re = re;
      this.im = 0;
    }
    public Complex times(Complex b) {
        float re = this.re * b.re - this.im * b.im;
        float im = this.re * b.im + this.im * b.re;
        return new Complex(re, im);
    }
    public Complex plus(Complex b) {
        float re = this.re + b.re;
        float im = this.im + b.im;
        return new Complex(re, im);
    }
    public Complex cexp() {
      float r = exp(this.re);
      return new Complex(r*cos(this.im),r*sin(this.im));
    }
    public float abs() {
      return sqrt(this.re*this.re + this.im*this.im);
    }
}
