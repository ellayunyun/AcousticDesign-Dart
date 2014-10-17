
part of PanelEditor;

class Template
{
	PanelEditor	_parent;
	
    Template(PanelEditor this._parent);
    
    void	showBackgroundUpload({ fileHandler, skipHandler })
    {
    	InputElement	fileInput;
    	ButtonElement	skipButton;
    	
    	_parent.container.nodes.clear();
    	
        fileInput = new InputElement()
            ..type = 'file'
            ..onChange.listen((_) => fileHandler(fileInput))
        ;
        
        skipButton = new ButtonElement()
        	..text = 'Skip'
        	..onClick.listen((_) => skipHandler())
    	;
        
        _parent.container
        	..append(fileInput)
        	//..append(skipButton)
    	;
    }
    
    CanvasElement	showBackgroundScaler()
    {
    	List<dynamic>	list;
    	CanvasElement	canvas;
    	double			ratio;
    	
    	if (_parent.backgroundImage == null)
    		return null;

    	canvas = new CanvasElement()
    		..className = 'background-scaler'
		;
    	
    	_parent.container.nodes.clear();
    	_parent.container
        	..append(canvas)
		;
		
		return canvas;
    }
    
    void	showScalingBubble({ callback })
    {
    	DivElement			bubble;
    	ParagraphElement	p;
    	FormElement			form;
    	InputElement		numberInput;
    	InputElement		submitInput;
    	
    	p = new ParagraphElement()
    		..text = 'Quelle est la taille réelle en centimètres de ce segment ?'
		;
    	
    	numberInput = new InputElement()
    		..type = 'number'
		;
    	
    	submitInput = new InputElement()
    		..type = 'submit'
    		..value = 'Valider'
		;
    	
    	form = new FormElement()
    		..append(p)
    		..append(numberInput)
    		..append(submitInput)
		;

    	bubble = new DivElement()
    		..className = 'scaling-bubble'
    		..append(form)
		;
    	
    	_parent.container.append(bubble);

		
		bubble.style.marginLeft = '${- bubble.offsetWidth / 2}px';
		
    	numberInput.focus();
    	
    	callback(
			bubble: bubble,
			form: form,
			numberInput: numberInput,
			submitInput: submitInput
    	);
    }
    
    void	showEditor({ callback })
    {
    	DivElement		leftContainer;
    	
    	leftContainer = new DivElement()
    		..className = 'container-left'
		;
    	
    	_parent.container.nodes.clear();
    	_parent.container
    		..append(leftContainer)
		;
    	
    	if (callback != null)
    		callback(
				leftContainer: leftContainer
			);
    }
    
    void	showPatternSelection({ buttonAction }) {
    	ButtonElement	button1;
    	ButtonElement	button2;
    	
    	button1 = new ButtonElement();
    	button1
    		..text = 'Panneau simple'
    		..onClick.listen((_) {
				if (buttonAction != null)
					buttonAction('monoptych');
			})
    	;

    	button2 = new ButtonElement();
    	button2
    		..text = 'Dyptique'
    		..onClick.listen((_) {
				if (buttonAction != null)
					buttonAction('diptych');
			})
    	;
    	
    	_parent.container.nodes.clear();
    	_parent.container
    		..append(button1)
    		..append(button2)
		;
    }
}