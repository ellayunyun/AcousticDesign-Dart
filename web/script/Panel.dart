
part of PanelEditor;

class Panel
{
	static List<Map>			_patterns;
	Editor						_editor;
	CanvasElement				_panel;
	DivElement					_panelWrapper;
	DivElement					_container;
	DivElement					_moveButton;
	DivElement					_soloButton;
	DivElement					_backgroundButton;
	Point						_imagePosition;
	double						_scale;
	double						_imageScale;
	Point						_position;
	int							_width;
	int							_height;
	ImageElement				_image;
	CanvasRenderingContext2D	_ctx;
	List<Panel>					_linkedPanels;
	Group						_group;
	bool						_solo;
	
	
	Panel({
		Editor			editor,
		DivElement		container,
		ImageElement	image,
		Point			position,
		int				width,
		int				height,
		Point			imagePosition,
		double			scale
	})
	{
		if (editor != null)
			_editor = editor;

		if (container != null)
			_container = container;

		_position = position;
		_width = width;
		_height = height;
		_image = image;
		_imagePosition = imagePosition;
		_imageScale = 1.0;
		_scale = scale;
		_linkedPanels = new List<Panel>();
		_solo = false;

		_build();
		
		print(_imagePosition.x);
	}
	
	void		_build()
	{
		_panel = new CanvasElement()
    		..className = 'panel'
		;
		
		_moveButton = new DivElement()
			..className = 'move'
		;
		
		_soloButton = new DivElement()
			..className = 'solo'
			..text = 'S'
		;
		
		_backgroundButton = new DivElement()
			..className = 'background'
			..text = 'B'
		;
    	
    	_panelWrapper = new DivElement()
    		..className = 'panel-wrapper'
    		..append(_panel)
    		..append(_moveButton)
    		..append(_backgroundButton)
    		..append(_soloButton)
		;

    	_container.append(_panelWrapper);

		_panel
			..width = (_width * _editor.scale).toInt()
			..height = (_height * _editor.scale).toInt()
		;
    	
    	moveBy(0, 0);
    	moveImage(new Point(0, 0));
    	
    	_bind();

		_ctx = _panel.getContext('2d');
	}
	
	void	_bind()
	{
    	_moveButton.onMouseDown.listen((MouseEvent e) {
			if (e.target == _moveButton)
				_editor.movingPanel = this;
		});
    	
    	_backgroundButton.onClick.listen((_) => _editor.changeBackground(this));
    	
    	_soloButton.onClick.listen((_) => toggleSolo());

		_panel
			..onMouseDown.listen((_) => _editor.movingImage = this)
			..onMouseWheel.listen((WheelEvent e) {
				if (_solo)
					scaleImage(e);
				else
					_editor.scaleGroupImages(_group, e);
			})
		;
	}
	
	void	toggleSolo()
	{
		_solo = !_solo;
		_soloButton.classes.toggle('active');
	}
	
	void	scaleImage(WheelEvent e)
	{
		double	newScale;

		newScale = (e.deltaY < 0)
			? _imageScale + _editor.scaleDelta
			: _imageScale - _editor.scaleDelta;

		if (_image.width * newScale < _panel.width
			|| _image.height * newScale < _panel.height)
			return ;
		
		_imageScale = newScale;
		
		moveImage(new Point(0, 0));
	}
	
	void	centerPosition()
	{
		move(
        	(_container.offsetWidth / 2 - _panel.offsetWidth / 2).toInt(),
        	(_container.offsetHeight / 2 - _panel.offsetHeight / 2).toInt()
        );
	}
	
	void	moveImage(Point delta)
	{
		int	x;
		int	y;

		x = (_imagePosition.x + delta.x / _imageScale).toInt();
		y = (_imagePosition.y + delta.y / _imageScale).toInt();
		
		x = Math.min(x, 0);
		y = Math.min(y, 0);
		
		/*
		print(x);
		print(_image.width);
		print(_imageScale);
		print(_panel.width);
		print((x * _imageScale + _image.width) * _imageScale);
		print('');
		*/
		/*
		-6822 // RELATIVE TO ZOOM
		2592
		0.20000000000000015
		246
		*/

		/*
		if ((x * _imageScale + _image.width) * _imageScale - _panel.width < 0) // WORKS
			x = ((- _image.width * _imageScale) * _imageScale + _panel.width).toInt();  // DOESN'T WORKS
		
		if (_image.height * _imageScale + y - _panel.height < 0)
			y = (- _image.height * _imageScale + _panel.height).toInt();
		*/
		_imagePosition = new Point(x, y);
	}

	void	move(int x, int y)
	{
		x = Math.max(x, 0);
		y = Math.max(y, 0);
		
		if (x + _panelWrapper.offsetWidth > _container.offsetWidth)
			x = _container.offsetWidth - _panelWrapper.offsetWidth;
		
		if (y + _panelWrapper.offsetHeight > _container.offsetHeight)
			y = _container.offsetHeight - _panelWrapper.offsetHeight;
		
		_position = new Point(x, y);
		
		_panelWrapper.style
			..left = '${_position.x}px'
			..top = '${_position.y}px'
		;
	}
	
	void	moveBy(int x, int y)
	{
		move(_position.x + x, _position.y + y);
	}
	
	void	draw(double time)
	{
		if (_image == null)
			return ;

		_ctx
			..fillRect(0, 0, _panel.width, _panel.height)
			..drawImageScaledFromSource(
        		_image, // Source
        		-_imagePosition.x * _imageScale, // Source X
        		-_imagePosition.y * _imageScale, // Source Y        		
        		_image.width, // Source width
        		_image.height, // Source height
        		0, // Destination X
        		0, // Destination Y
        		_image.width * _imageScale, // Destination width
        		_image.height * _imageScale // Destination height
        	)
    	;
	}
	
	set		image(ImageElement image)	=>	_image = image;
	
	set		group(Group group)
	{
		_group = group;
		_moveButton.style.backgroundColor = group.color;
	}
	
	get		group						=> _group;
	get		solo						=> _solo;
}