For use in Rails project, add this line to Gemfile
```ruby
gem 'simple_uri'
```

Examples:

```ruby
SimpleUri.send_request(url: 'http://somesite.com/qwerty/', method: :post)
```

```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
SimpleUri.send_request(url: 'http://somesite.com/qwerty/', method: :post, req_body: 'a=1', req_headers: headers)
```

```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
body = SimpleUri.body_to_str_params({ a: 1, b: 2 })
SimpleUri.send_request(url: 'http://somesite.com/qwerty/', method: :post, req_body: body, req_headers: headers)
```


If used http basic authentication, you can use `user` and `password` parameters:
```ruby
SimpleUri.send_request(url: some_url, method: :post, user: 'my_user', password: 'my_password')
```

You can also get cookies:
```ruby
SimpleUri.send_request(url: some_url, method: :get, cookies: true)
```

To enable debug_mode - use `debug: true` parameter:
```ruby
SimpleUri.send_request(url: some_url, method: :get, debug: true)
```
