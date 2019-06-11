---
date: 2019-06-11
tags: ruby mock rspec
---

To mock a class method:
```ruby
allow(Time).to(receive(:utc).and_return(
   Time.now.utc.change(hour: 9, minute: 0)
))
```
To mock any class instance method:

```ruby
allow_any_instance_of(Time).to(receive(:utc).and_return(
   Time.now.utc.change(hour: 9, minute: 0)
))
```

To reset for next test:
```ruby
allow_any_instance_of(Time).to(receive(:utc).and_call_original
```
