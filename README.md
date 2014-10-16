Gem available for `ruby > 1.9` version

For use in Rails project, add this line to Gemfile
```ruby
gem 'simple_uri'
```

Examples:

```ruby
SimpleUri.send_request('http://somesite.com/qwerty/') #by default used GET method
SimpleUri.req('http://somesite.com/qwerty/')
```
`req` and `send_request` alias methods


```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
body = 'a=1&b=2'
SimpleUri.req('http://somesite.com/qwerty/', :post, { req_body: body, req_headers: headers })
```

```ruby
headers = { 'HEADER-X' => '1',
            'HEADER-Y' => '2' }
body = { a: 1, b: 2 }
SimpleUri.req('http://somesite.com/qwerty/', :post, { req_body: body, req_headers: headers })
```


If used http basic authentication, you can use `user` and `password` parameters:
```ruby
SimpleUri.req(some_url, :post, { user: 'my_user', password: 'my_password' })
```

You can also get cookies:
```ruby
SimpleUri.req(some_url, :get, { cookies: true })
```

To enable debug_mode - use `debug: true` parameter:
```ruby
SimpleUri.req(some_url, :get, { debug: true })
```
