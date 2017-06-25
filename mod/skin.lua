
local color = {
	text = '#FFFFFFFF',
	primary = '#333333FF',
	secondary = '#222222FF',
	highlight = '#111111FF',
}

return {
	['font'] =  love.graphics.newFont("res/tewi-medium-11.bdf", 11),
	['text'] = {
		['color'] = color.text,
		['padding'] = {x = 1, y = 2}
	},
	['button'] = {
		['normal'] = color.primary,
		['hover'] = color.secondary,
		['active'] = color.highlight,
		['border color'] = color.highlight,
		['text background'] = color.highlight,
		['text normal'] = color.text,
		['text hover'] = color.text,
		['text active'] = color.text,
		['text alignment'] = 'centered',
		['border'] = 1,
		['rounding'] = 0,
		['padding'] = {x = 2, y = 2},
		['image padding'] = {x = 2, y = 2},
		['touch padding'] = {x = 2, y = 2}
	},
	['contextual button'] = {
		['normal'] = color.primary,
		['hover'] = color.secondary,
		['active'] = color.highlight,
		['border color'] = color.highlight,
		['text background'] = color.highlight,
		['text normal'] = color.text,
		['text hover'] = color.text,
		['text active'] = color.text,
		['text alignment'] = 'centered',
		['border'] = 1,
		['rounding'] = 0,
		['padding'] = {x = 2, y = 2},
		['image padding'] = {x = 2, y = 2},
		['touch padding'] = {x = 2, y = 2}
	},

	--[[
	['menu button'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['text background'] = color,
		['text normal'] = color,
		['text hover'] = color,
		['text active'] = color,
		['text alignment'] = align,
		['border'] = number,
		['rounding'] = number,
		['padding'] = {x = number, y = number},
		['image padding'] = {x = number, y = number},
		['touch padding'] = {x = number, y = number}
	},
	['option'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['text normal'] = color,
		['text hover'] = color,
		['text active'] = color,
		['text background'] = color,
		['text alignment'] = align,
		['padding'] = {x = number, y = number},
		['touch padding'] = {x = number, y = number},
		['spacing'] = number,
		['border'] = number
	},
	['checkbox'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['text normal'] = color,
		['text hover'] = color,
		['text active'] = color,
		['text background'] = color,
		['text alignment'] = align,
		['padding'] = {x = number, y = number},
		['touch padding'] = {x = number, y = number},
		['spacing'] = number,
		['border'] = number
	},
	['selectable'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['pressed'] = color or Image,
		['normal active'] = color or Image,
		['hover active'] = color or Image,
		['pressed active'] = color or Image,
		['text normal'] = color,
		['text hover'] = color,
		['text pressed'] = color,
		['text normal active'] = color,
		['text hover active'] = color,
		['text pressed active'] = color,
		['text background'] = color,
		['text alignment'] = align,
		['rounding'] = number,
		['padding'] = {x = number, y = number},
		['touch padding'] = {x = number, y = number},
		['image padding'] = {x = number, y = number}
	},
	['slider'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['bar normal'] = color,
		['bar active'] = color,
		['bar filled'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['cursor active'] = color or Image,
		['border'] = number,
		['rounding'] = number,
		['bar height'] = number,
		['padding'] = {x = number, y = number},
		['spacing'] = {x = number, y = number},
		['cursor size'] = {x = number, y = number}
	},
	['progress'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['cursor active'] = color or Image,
		['cursor border color'] = color,
		['rounding'] = number,
		['border'] = number,
		['cursor border'] = number,
		['cursor rounding'] = number,
		['padding'] = {x = number, y = number}
	},
	['property'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['label normal'] = color,
		['label hover'] = color,
		['label active'] = color,
		['border'] = number,
		['rounding'] = number,
		['padding'] = {x = number, y = number},
		['edit'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['scrollbar'] = {
				['normal'] = color or Image,
				['hover'] = color or Image,
				['active'] = color or Image,
				['border color'] = color,
				['cursor normal'] = color or Image,
				['cursor hover'] = color or Image,
				['cursor active'] = color or Image,
				['cursor border color'] = color,
				['border'] = number,
				['rounding'] = number,
				['border cursor'] = number,
				['rounding cursor'] = number,
				['padding'] = {x = number, y = number}
			},
			['cursor normal'] = color,
			['cursor hover'] = color,
			['cursor text normal'] = color,
			['cursor text hover'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['selected normal'] = color,
			['selected hover'] = color,
			['selected text normal'] = color,
			['selected text hover'] = color,
			['border'] = number,
			['rounding'] = number,
			['cursor size'] = number,
			['scrollbar size'] = {x = number, y = number},
			['padding'] = {x = number, y = number},
			['row padding'] = number
		},
		['inc button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		},
		['dec button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		}
	},
	['edit'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['scrollbar'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['cursor normal'] = color or Image,
			['cursor hover'] = color or Image,
			['cursor active'] = color or Image,
			['cursor border color'] = color,
			['border'] = number,
			['rounding'] = number,
			['border cursor'] = number,
			['rounding cursor'] = number,
			['padding'] = {x = number, y = number}
		},
		['cursor normal'] = color,
		['cursor hover'] = color,
		['cursor text normal'] = color,
		['cursor text hover'] = color,
		['text normal'] = color,
		['text hover'] = color,
		['text active'] = color,
		['selected normal'] = color,
		['selected hover'] = color,
		['selected text normal'] = color,
		['selected text hover'] = color,
		['border'] = number,
		['rounding'] = number,
		['cursor size'] = number,
		['scrollbar size'] = {x = number, y = number},
		['padding'] = {x = number, y = number},
		['row padding'] = number
	},
	['chart'] = {
		['background'] = color or Image,
		['border color'] = color,
		['selected color'] = color,
		['color'] = color,
		['border'] = number,
		['rounding'] = number,
		['padding'] = {x = number, y = number}
	},
	['scrollh'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['cursor active'] = color or Image,
		['cursor border color'] = color,
		['border'] = number,
		['rounding'] = number,
		['border cursor'] = number,
		['rounding cursor'] = number,
		['padding'] = {x = number, y = number}
	},
	['scrollv'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['cursor normal'] = color or Image,
		['cursor hover'] = color or Image,
		['cursor active'] = color or Image,
		['cursor border color'] = color,
		['border'] = number,
		['rounding'] = number,
		['border cursor'] = number,
		['rounding cursor'] = number,
		['padding'] = {x = number, y = number}
	},
	--]]
	['tab'] = {
		--[[
		['background'] = color or Image,
		['border color'] = color,
		['text'] = color,
		['tab maximize button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		},
		['tab minimize button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		},
		--] ]
		['node maximize button'] = {
			['normal'] = color.primary,
			['hover'] = color.secondary,
			['active'] = color.highlight,
			['border color'] = color.highlight,
			['text background'] = color.highlight,
			['text normal'] = color.text,
			['text hover'] = color.text,
			['text active'] = color.text,
			['text alignment'] = 'left',
			['border'] = 1,
			['rounding'] = 0,
			['padding'] = {x = 2, y = 2},
			['image padding'] = {x = 2, y = 2},
			['touch padding'] = {x = 2, y = 2}
		},
		--[[
		['node minimize button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		},
		--[[
		['border'] = number,
		['rounding'] = number,
		['indent'] = number,
		['padding'] = {x = number, y = number},
		['spacing'] = {x = number, y = number}
		--]]
	},
	--[[
	['combo'] = {
		['normal'] = color or Image,
		['hover'] = color or Image,
		['active'] = color or Image,
		['border color'] = color,
		['label normal'] = color,
		['label hover'] = color,
		['label active'] = color,
		['symbol normal'] = color,
		['symbol hover'] = color,
		['symbol active'] = color,
		['button'] = {
			['normal'] = color or Image,
			['hover'] = color or Image,
			['active'] = color or Image,
			['border color'] = color,
			['text background'] = color,
			['text normal'] = color,
			['text hover'] = color,
			['text active'] = color,
			['text alignment'] = align,
			['border'] = number,
			['rounding'] = number,
			['padding'] = {x = number, y = number},
			['image padding'] = {x = number, y = number},
			['touch padding'] = {x = number, y = number}
		},
		['border'] = number,
		['rounding'] = number,
		['content padding'] = {x = number, y = number},
		['button padding'] = {x = number, y = number}
		['spacing'] = {x = number, y = number}
	},
	--]]
	['window'] = {
		['header'] = {
			['normal'] = color.primary,
			['hover'] = color.secondary,
			['active'] = color.highlight,
			--[[
			['close button'] = {
				['normal'] = color or Image,
				['hover'] = color or Image,
				['active'] = color or Image,
				['border color'] = color,
				['text background'] = color,
				['text normal'] = color,
				['text hover'] = color,
				['text active'] = color,
				['text alignment'] = align,
				['border'] = number,
				['rounding'] = number,
				['padding'] = {x = number, y = number},
				['image padding'] = {x = number, y = number},
				['touch padding'] = {x = number, y = number}
			},
			['minimize button'] = {
				['normal'] = color or Image,
				['hover'] = color or Image,
				['active'] = color or Image,
				['border color'] = color,
				['text background'] = color,
				['text normal'] = color,
				['text hover'] = color,
				['text active'] = color,
				['text alignment'] = align,
				['border'] = number,
				['rounding'] = number,
				['padding'] = {x = number, y = number},
				['image padding'] = {x = number, y = number},
				['touch padding'] = {x = number, y = number}
			},
			['label normal'] = color,
			['label hover'] = color,
			['label active'] = color,
			['padding'] = {x = number, y = number},
			['label padding'] = {x = number, y = number},
			['spacing'] = {x = number, y = number},
			]]
		},
		['fixed background'] = '#2d2d2daa',
		['background'] = '#00000000',
		['border color'] = color.highlight,
		--[[
		['popup border color'] = color,
		['combo border color'] = color,
		['contextual border color'] = color,
		['menu border color'] = color,
		['group border color'] = color,
		['tooltip border color'] = color,
		['scaler'] = color or Image,
		['border'] = number,
		['combo border'] = number,
		['contextual border'] = number,
		['menu border'] = number,
		['group border'] = number,
		['tooltip border'] = number,
		['popup border'] = number,
		['rounding'] = number,
		['spacing'] = {x = number, y = number},
		['scrollbar size'] = {x = number, y = number},
		['min size'] = {x = number, y = number},
		['padding'] = {x = number, y = number},
		['group padding'] = {x = number, y = number},
		['popup padding'] = {x = number, y = number},
		['combo padding'] = {x = number, y = number},
		['contextual padding'] = {x = number, y = number},
		['menu padding'] = {x = number, y = number},
		['tooltip padding'] = {x = number, y = number}
		]]
	}
}