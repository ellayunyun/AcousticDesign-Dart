
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
	DivElement					_resizeButton;
	DivElement					_widthDimension;
	DivElement					_heightDimension;
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
	}
	
	void		_build()
	{
		_panel = new CanvasElement()
    		..className = 'panel'
		;
		
		_moveButton = new DivElement()
			..className = 'move'
			..title = 'Move'
		;
		
		_soloButton = new DivElement()
			..className = 'solo'
			..text = 'S'
			..title = 'Solo'
		;
		
		_backgroundButton = new DivElement()
			..className = 'background'
			..text = 'B'
			..title = 'Background'
		;
		
		_resizeButton = new DivElement()
			..className = 'resize'
			..text = 'R'
			..title = 'Resize'
		;
		
		_widthDimension = new DivElement()
			..className = 'dimension-width'
			..text = _width.toString() +' cm'
		;
		
		_heightDimension = new DivElement()
			..className = 'dimension-height'
			..text = _height.toString() +' cm'
		;
		
		
    	
    	_panelWrapper = new DivElement()
    		..className = 'panel-wrapper'
    		..append(_panel)
    		..append(_moveButton)
    		..append(_backgroundButton)
    		..append(_soloButton)
    		..append(_resizeButton)
    		..append(_widthDimension)
    		..append(_heightDimension)
		;

    	_container.append(_panelWrapper);

		_panel
			..width = (_width * _editor.scale).toInt()
			..height = (_height * _editor.scale).toInt()
		;
		
		_heightDimension.style
			..width = _panel.height.toString() +'px'
			..left = (- _panel.height / 2 - 10).toString() +'px'
		;
    	
    	moveBy(0, 0);
    	moveImageBy(new Point(0, 0));
    	
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
    	
    	_resizeButton
	    	..onMouseDown.listen((_) {
	    		_editor.resizingPanel = this;
	    	})
    	;

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
	
	void	resizeBy(Point delta)
	{
		int						newWidth;
		int						newHeight;
		int						realWidth;
		int						realHeight;
		Map<String, dynamic>	config;
		
		config = _editor.config['panel'];
		
		newWidth = _panel.width + delta.x;
		newHeight = _panel.height + delta.y;
		
		realWidth = newWidth ~/ _scale;
		realHeight = newHeight ~/ _scale;
		
		if (realWidth >= config['min_width']
		  && realWidth <= config["max_width"]
		  && int.parse(_panelWrapper.style.left.replaceAll('px', '')) + newWidth < _editor.leftContainer.clientWidth)
			_panel.width = newWidth;
		
		if (realHeight >= config['min_height']
			&& realHeight <= config["max_height"]
		  	&& int.parse(_panelWrapper.style.top.replaceAll('px', '')) + newHeight < _editor.leftContainer.clientHeight)
			_panel.height = newHeight;
		
		_widthDimension.text = realWidth.toString() +' cm';
		_heightDimension.text = realHeight.toString() +' cm';
		
		centerImage();
	}
	
	void	toggleSolo()
	{
		_solo = !_solo;
		_soloButton.classes.toggle('active');
	}
	
	void	centerImage()
	{
		int		x;
		int		y;
		_imageScale = 1.0;
		x = (_panel.width ~/ 2) * _imageScale.toInt() - _image.width ~/ 2;
		y = (_panel.height ~/ 2) * _imageScale.toInt() - _image.height ~/ 2;
		
		_imagePosition = new Point(x, y);
		moveImageBy(new Point(0, 0));
	}
	
	void	scaleImage(WheelEvent e)
	{
		double	newScale;

		newScale = (e.deltaY < 0)
			? _imageScale + _editor.scaleDelta
			: _imageScale - _editor.scaleDelta
		;

		/*
		if (_image.width * newScale < _panel.width
			|| _image.height * newScale < _panel.height)
			return ;
		*/
		
		_imageScale = newScale;
		
		moveImageBy(new Point(0, 0));
	}
	
	void	centerPosition()
	{
		move(
        	(_container.offsetWidth / 2 - _panel.offsetWidth / 2).toInt(),
        	(_container.offsetHeight / 2 - _panel.offsetHeight / 2).toInt()
        );
	}
	
	void	moveImageBy(Point delta)
	{
		int	x;
		int	y;

		x = (_imagePosition.x + delta.x).toInt();
		y = (_imagePosition.y + delta.y).toInt();
		
		/*
		x = Math.min(x, 0);
		y = Math.min(y, 0);
		*/
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
        		0, // Source X
        		0, // Source Y        		
        		_image.width, // Source width
        		_image.height, // Source height
        		_imagePosition.x, // Destination X
        		_imagePosition.y, // Destination Y
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