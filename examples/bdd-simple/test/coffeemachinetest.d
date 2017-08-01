import checkit;

import coffeemachine;

unittest
{
  scenario!("Buy last coffee", ["coffee"])
  ({
    given!"There are 1 coffees left in the machine And I have deposited 1 dollar"
    ({
      auto machine = new CoffeeMachine(1);
      machine.deposit(1);
      
      when!"I press the coffee button"
      ({
        auto coffee = machine.buy();

        then!"I should be served a coffee"
        ({
          coffee.shouldNotBeNull();
        });
      });
    });
  });
}
