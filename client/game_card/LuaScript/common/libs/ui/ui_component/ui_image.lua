
UIImage = UIImage or class("UIImage", UIComponent)

function UIImage:ctor(go)
    self.img_comp = UIHelp.get_component(CSharpType.UIImage, go)
    assert(CSharpHelp.not_null(self.img_comp))
    UIImage.super.ctor(self, go)
    self.sprite_asset_path = nil
end

function UIImage:is_available()
    if not UIImage.super.is_available(self) then
        return false
    end
    if CSharpHelp.is_null(self.img_comp) then
        return false
    end
    return true
end


function UIImage:set_color(color)
    if CSharpHelp.is_null(color) or not self:is_available() then
        return false
    end
    self.img_comp.color = color
    return true
end

function UIImage:get_color()
    if not self:is_available() then
        return nil
    end
    return self.img_comp.color
end

function UIImage:set_sprite(asset_path, cb_fn, is_set_size)
    asset_path = asset_path or ""
    self.sprite_asset_path = asset_path
    if not self:is_available() then
        return false
    end
    UIHelp.set_image_sprite(self.img_comp, asset_path, cb_fn, is_set_size)
end

function UIImage:get_sprite_asset_path()
    return self.sprite_asset_path
end

function UIImage:set_fill_amount(val)
    if not self:is_available() then
        return false
    end
    self.img_comp.fillAmount = val
    return true
end

function UIImage:get_fill_amount()
    if not self:is_available() then
        return nil
    end
    return self.img_comp.fillAmount
end

function UIImage:on_destroy()
    UIImage.super.on_destroy(self)
    self.img_comp = nil
end




