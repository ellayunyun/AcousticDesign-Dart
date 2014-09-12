
part of PanelEditor;

class BackgroundScaler
{
	bool						_scaling;
	CanvasElement				_canvas;
	ImageElement				_image;
	CanvasRenderingContext2D	_ctx;
	Point						_start;
	Point						_end;
	Template					_template;
	DivElement					_bubble;
	DivElement					_numberInput;
	var							_callback;
	
	BackgroundScaler({
			Template		template,
			CanvasElement	canvas,
			ImageElement	image,
							callback
		})
	{
		double	ratio;

		_template = template;
		_canvas = canvas;
		_image = image;
		_callback = callback;
		
		ratio = _canvas.offsetWidth / _image.width;
		_canvas.style.height = (_image.height * ratio).toInt().toString() +'px';
		
		_scaling = false;
		_ctx = _canvas.getContext('2d');
		_canvas
			..onMouseDown.listen(_startScaling)
			..onMouseUp.listen(_stopScaling)
			..onMouseMove.listen(_scale)
			..width = _canvas.offsetWidth
			..height = _canvas.offsetHeight
		;
		window.requestAnimationFrame(_draw);
	}
	
	void	_draw(double time)
	{
		_ctx.drawImageScaledFromSource(
			_image,
			0,
			0,
			_image.width,
			_image.height,
			0,
			0,
			_canvas.width,
			_canvas.height
		);
		
		if (_bubble != null)
			_ctx
				..fillStyle = 'rgba(0, 0, 0, .3)'
				..fillRect(0, 0, _canvas.width, _canvas.height)
			;
		
		_drawRuler();
		window.requestAnimationFrame(_draw);
	}
	
	void	_startScaling(MouseEvent event)
	{
		_scaling = true;
		_start = event.offset;
		_end = null;
		
		if (_bubble != null) {
			_bubble.remove();
			_bubble = null;
		}
	}
	
	void	_scale(MouseEvent event)
	{
		if (!_scaling)
			return ;

		_end = event.offset;
	}
	
	void	_stopScaling(MouseEvent event)
	{
		Point	point;
		double	x;
		double	y;
		
		_scaling = false;
		_end = event.offset;
		
		if (_end == _start)
			return ;
		
		_template.showScalingBubble(
			callback: _bindTemplate
		);
	}
	
	void	_bindTemplate({
				DivElement		bubble,
				FormElement		form,
				InputElement	numberInput,
				InputElement	submitInput
			})
	{
		double	scale;
		int		number;
		
		_bubble = bubble;
		
		form.onSubmit.listen((Event e) {
			e.preventDefault();
			
			number = int.parse(numberInput.value);
			
			if (number <= 0) {
				window.alert('bad scaling');
				return ;
			}
			
			scale = _start.distanceTo(_end) / number;
			
			_callback(scale: scale);
		});
	}
	
	void	_drawRuler()
	{
		Point		vector;
		double		vectorLength;
		const int	boundaryLineLength = 10;
		Point		boundaryLine;
		
		if (_start != null && _end != null) {
			
			// Line's vector
			vector = new Point(_start.y - _end.y, - (_start.x - _end.x));
			// Perpendicular vector
			vectorLength = Math.sqrt(vector.x * vector.x + vector.y * vector.y);
			// Normalization
			vector *= 1 / vectorLength;
			// To final size
			vector *= boundaryLineLength;

			_ctx
				..strokeStyle = '#ff0000'
				..shadowBlur = 8
				..shadowColor = 'rgba(0, 0, 0, .7)'
				..lineWidth = 4
				
				..beginPath()
				..moveTo(_start.x, _start.y)
    			..lineTo(_end.x, _end.y)

				..moveTo(
					_start.x - vector.x,
					_start.y - vector.y
				)
				..lineTo(
					_start.x + vector.x,
					_start.y + vector.y
				)
				
				..moveTo(
            		_end.x - vector.x,
            		_end.y - vector.y
            	)
            	..lineTo(
            		_end.x + vector.x,
            		_end.y + vector.y
            	)
				
				..stroke()
			;
		}
	}
}