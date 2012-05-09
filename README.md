Pgq Rails
=========

Queues system for AR/Rails based on PgQ Skytools for PostgreSQL, like Resque on Redis. Rails 3! only tested.
 
About PgQ
*  http://wiki.postgresql.org/wiki/SkyTools#PgQ


Install
-------

Install skytools:
Ubuntu 11.10: 

    # apt-get install postgresql-server postgresql-client
    # apt-get install skytools

Gemfile:

```ruby
gem 'pgq'
```

Create ticker configs:

    $ rails generate pgq:config
    edit config: config/pgq_development.ini


Install pgq to database (if test database recreates all the time, should reinstall pgq each time):

    $ rake pgq:install
    or execute
    $ pgqadm config/pgq_development.ini install

   

Run ticker daemon (ticker needs on production database, or development if we test the process of consuming):
Daemon run once, bind to the database. (If worker not consuming check that daemon started).

    $ rake pgq:ticker:start (stop)
    or execute
    $ pgqadm config/pgq_development.ini ticker -d
    

Last, add to config/application.rb

    config.autoload_paths += %W( #{config.root}/app/models/pgq )
    

Create Pgq consumer
-------------------

    $ rails generate pgq:add my


This creates file app/models/pgq/pgq_my.rb and migration

    $ rake db:migrate


```ruby
class PgqMy < Pgq::Consumer

  def some_method1(a, b, c)
    logger.info "async call some_method1 with #{[a, b, c].inspect}"
  end
  
  def some_method2(x)
    logger.info "async called some_method2 with #{x.inspect}"
  end
  
end
```

Insert event into queue like this:

    PgqMy.some_method1(1, 2, 3)
    
    or
        
    PgqMy.add_event(:some_method2, some_x)
            
    or
    
    PgqMy.enqueue(:some_method1, 1, 2, 3)
  

Workers
-------
Start worker for queue:

    $ rake pgq:worker QUEUES="my"
    $ rake pgq:worker QUEUES="my,mailer,other"
    $ rake pgq:worker QUEUES="all" RAILS_ENV=production
    


Also possible consume by hands, or write [bin_script](http://github.com/kostya/bin_script) like this:
```ruby
class PgqRunnerScript < BinScript

  self.enable_locking = false

  required :q, "queues separated by ','"
  required :w, "watch file"
  
  def queue
    params(:q)
  end
      
  def do!
    $0 = "ruby pgq #{queue} > #{params(:l)}"
    worker = Pgq::Worker.new(:logger => self.logger, :queues => queue, :watch_file => params(:w) || "#{Rails.root}/tmp/stop_#{queue}.txt")
    worker.run
  end
                                                                     
end
```

and run:

    $ ./bin/pgq_runner.rb -q my -l ./log/pgq_my.log
    $ ./bin/pgq_runner.rb -q all -l ./log/pgq_all.log   # this will consume all queues from config/queues_list.yml




### Admin interface
Admins interface is possible like Resque, but not realized yet.
For queues info, run in console:

    > Pgq::Consumer.pgq_get_consumer_info


### Failed events
When any raise happens in consumer, its produce failed event, which can be retry, or delete.

Retry manual:

    Pgq::Consumer.resend_failed_events(queue_name)

Delete manual:
    
    Pgq::Consumer.clear_failed_events(queue_name)


### Divide events between workers, for one consumer class
create more queues: my_2, my_3

```ruby
class PgqMy < Pgq::Consumer

  QUEUES = %w(my my_2 my_3).freeze

  def self.next_queue_name
    QUEUES.choice
  end
  
end
```
And run 3 workers: for my, my_2, my_3




### Consume group of events extracted from pgq(batch): 

```ruby
class PgqMy < Pgq::ConsumerGroup

  # {'type' => [events]}
  def perform_group(events_hash)
    raise "realize me"
  end
  
end
```



### Options
create initializer with:

```ruby
class Pgq::Consumer

  # specify database with pgq queues
  def self.database
    SomeDatabase 
  end

  # specify coder  
  def self.coder
    Pgq::Marshal64Coder
  end
    
end
```

### Proxy method to consumer
Usefull in specs

``` ruby
  PgqMy.proxy(:some_method1)
```
 
When code call PgqMy.some_method1(a,b,c) this would be convert into PgqMy.new.some_method1(a,b,c)
  