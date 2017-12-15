#include <iostream>

class CelestialBody
{
 public:
   CelestialBody(double mass) : _mass(mass) {
     std::cout << "Creating celestial body of mass " << _mass << "\n";
   }

   ~CelestialBody() {
      std::cout << "Destroying celestial body of mass " << _mass << "\n";
   }

 private:
   const double _mass;
};

class Star : public CelestialBody  // Star is a CelestialBody.
{
 public:
   Star(double mass, double brightness) 
                           : CelestialBody(mass), _brightness(brightness) {
     std::cout << "Creating a star of brightness " << _brightness << "\n";
   }

   ~Star() {
       std::cout << "Destroying a star of brightness " << _brightness << "\n";
   }

 private:
   const double _brightness;
};

class Planet : public CelestialBody  // Planet is a CelestialBody.
{
 public:
   Planet(int mass, int albedo) : CelestialBody(mass), _alb(albedo) {
     std::cout << "CelestialBody Planet albedo is " << _alb << std::endl;
   }
 private:
   int _alb;
};


int main(void) {
  std::cout << "    Entering main.\n";
  ///Star aStar(1234.5, 0.1);
  Planet planetobj(5, 10);
  std::cout << "    Exiting main.\n";
  
  return 0;
}
 
