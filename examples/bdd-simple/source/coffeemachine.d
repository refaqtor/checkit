module coffeemachine;

import coffee;

class CoffeeMachine
{
  public:
    this(ushort count)
    {
      _count = count;
    }

    void deposit(double dollars)
    {
      _deposit = dollars;
    }

    Coffee buy()
    {
      return new Coffee;
    }

  private:
    ushort _count;
    double _deposit;
}
