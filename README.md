grunt-praless
=============

Less with namespaces @require / @provide instead of file based import

Gruntfile.coffee
```coffeescript

grunt.loadNpmTasks 'grunt-praless'

praless:
	all:
		options:
			dest: 'client/app/css/app.css'
			base: 'app.start'
		files: [
			expand: true
			src: ['src/**/*.less']
		]


```


example
-------


##### app.less

```css
// less entry point - set in options base
@provide 'app.start';

@require 'ui.button';
```


##### some/folder/mixins.less
```css
@provide 'mixins';

.mix(@c) {
	color: @c;
}
```

##### some/component/ui/button.less
```css
@require 'mixins';

@provide 'ui.button';

.b-button {
	.mix(red);
}

