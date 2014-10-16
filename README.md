Gem available for ruby 2.1 version

For use in Rails project, add this line to Gemfile
```ruby
gem 'simple_uri'
```

Examples:

```ruby
SimpleUri.send_request('http://somesite.com/qwerty/') #by default used GET request
```

```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
body = 'a=1&b=2'
SimpleUri.send_request('http://somesite.com/qwerty/', :post, { req_body: body, req_headers: headers })
```

```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
body = { a: 1, b: 2 }
SimpleUri.send_request('http://somesite.com/qwerty/', :post, { req_body: body, req_headers: headers })
```


If used http basic authentication, you can use `user` and `password` parameters:
```ruby
SimpleUri.send_request(some_url, :post, { user: 'my_user', password: 'my_password' })
```

You can also get cookies:
```ruby
SimpleUri.send_request(some_url, :get, { cookies: true })
```

To enable debug_mode - use `debug: true` parameter:
```ruby
SimpleUri.send_request(some_url, :get, { debug: true })
```
