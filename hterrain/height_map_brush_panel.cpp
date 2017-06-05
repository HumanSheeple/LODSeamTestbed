#include "height_map_brush_panel.h"

void HeightMapBrushPanel::_brush_mode(int b_mode) {
    switch (b_mode){
        case TERRAIN_BRUSH_MODE_ADD: {
        _Terrain_Flatten_Height_Line_Edit->set_editable(false);
        }break;
        case TERRAIN_BRUSH_MODE_SUBTRACT:{
         _Terrain_Flatten_Height_Line_Edit->set_editable(false);
        }break;
        case TERRAIN_BRUSH_MODE_SMOOTH:{
         _Terrain_Flatten_Height_Line_Edit->set_editable(false);
        }break;
        case TERRAIN_BRUSH_MODE_FLATTEN:{
         _Terrain_Flatten_Height_Line_Edit->set_editable(true);
        }break;
        case TERRAIN_BRUSH_MODE_TEXTURE:{
         _Terrain_Flatten_Height_Line_Edit->set_editable(false);
        }break;
    }
}

void HeightMapBrushPanel::_on_size_slider_value_changed(int size_value){
    String size_string;
    size_string = String::num(size_value);
    _Terrain_Size_Line_Edit->set_text(size_string);
}

void HeightMapBrushPanel::_on_size_line_edit_entered(String size_text){
    int size_value;
    size_value = String(size_text).to_int();
    _Terrain_Size_HSlider->set_value(size_value);
}

void HeightMapBrushPanel::_on_opacity_slider_value_changed(int opacity_value){
    String opacity_line_edit_string;
    opacity_line_edit_string = String::num(opacity_value);
    _Terrain_Opacity_Line_Edit->set_text(opacity_line_edit_string);
}

void HeightMapBrushPanel::_on_opacity_line_edit_entered(String opacity_text){
    int opacity_slider_value;
    opacity_slider_value = String(opacity_text).to_int();
    _Terrain_Opacity_HSlider->set_value(opacity_slider_value);
}

void HeightMapBrushPanel::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_brush_mode", "b_mode"), &HeightMapBrushPanel::_brush_mode);
    ClassDB::bind_method(D_METHOD("_on_size_slider_value_changed", "size_value"), &HeightMapBrushPanel::_on_size_slider_value_changed);
    ClassDB::bind_method(D_METHOD("_on_size_line_edit_entered", "size_text"), &HeightMapBrushPanel::_on_size_line_edit_entered);
    ClassDB::bind_method(D_METHOD("_on_opacity_slider_value_changed", "opacity_value"), &HeightMapBrushPanel::_on_opacity_slider_value_changed);
    ClassDB::bind_method(D_METHOD("_on_opacity_line_edit_entered", "opacity_text"), &HeightMapBrushPanel::_on_opacity_line_edit_entered);


    BIND_CONSTANT(TERRAIN_BRUSH_MODE_ADD);
    BIND_CONSTANT(TERRAIN_BRUSH_MODE_SUBTRACT);
    BIND_CONSTANT(TERRAIN_BRUSH_MODE_SMOOTH);
    BIND_CONSTANT(TERRAIN_BRUSH_MODE_FLATTEN);
    BIND_CONSTANT(TERRAIN_BRUSH_MODE_TEXTURE);

}

HeightMapBrushPanel::HeightMapBrushPanel() {

	set_custom_minimum_size(Vector2(35, 112));
    _Terrain_Brush_Mode_Selector = memnew(HButtonArray);
    _Terrain_Brush_Mode_Selector->add_button("Add", "Increase Terrain Height");
    _Terrain_Brush_Mode_Selector->add_button("Subtract", "Decrease Terrain Height");
    _Terrain_Brush_Mode_Selector->add_button("Smooth", "Smooth Terrain");
    _Terrain_Brush_Mode_Selector->add_button("Flatten", "Level the terrain to X height");
    _Terrain_Brush_Mode_Selector->add_button("Texture", "Paint Terrain");
    _Terrain_Brush_Mode_Selector->set_position(Vector2(20,0));
    _Terrain_Brush_Mode_Selector->connect("button_selected", this, "_brush_mode");
    add_child(_Terrain_Brush_Mode_Selector);
    _Terrain_Size_Label = memnew(Label);
    _Terrain_Size_Label->set_text("Size");
    _Terrain_Size_Label->set_position(Vector2(20,35));
    add_child(_Terrain_Size_Label);
    _Terrain_Opacity_Label = memnew(Label);
    _Terrain_Opacity_Label->set_text("Opacity");
    _Terrain_Opacity_Label->set_position(Vector2(20,60));
    add_child(_Terrain_Opacity_Label);
    _Terrain_Flatten_Height_Label = memnew(Label);
    _Terrain_Flatten_Height_Label->set_text("Flatten Height");
    _Terrain_Flatten_Height_Label->set_position(Vector2(20,85));
    add_child(_Terrain_Flatten_Height_Label);
    _Terrain_Size_HSlider = memnew(HSlider);
    _Terrain_Size_HSlider->set_size(Vector2(150, 16));
    _Terrain_Size_HSlider->set_position(Vector2(80,35));
    _Terrain_Size_HSlider->set_min(1);
    _Terrain_Size_HSlider->set_max(25);
    _Terrain_Size_HSlider->set_step(1);
    _Terrain_Size_HSlider->connect("value_changed", this, "_on_size_slider_value_changed");
    add_child(_Terrain_Size_HSlider);
    _Terrain_Opacity_HSlider = memnew(HSlider);
    _Terrain_Opacity_HSlider->set_size(Vector2(150, 16));
    _Terrain_Opacity_HSlider->set_position(Vector2(80,60));
    _Terrain_Opacity_HSlider->set_min(0);
    _Terrain_Opacity_HSlider->set_max(200);
    _Terrain_Opacity_HSlider->set_step(1);
    _Terrain_Opacity_HSlider->connect("value_changed", this, "_on_opacity_slider_value_changed");
    add_child(_Terrain_Opacity_HSlider);
    _Terrain_Size_Line_Edit = memnew(LineEdit);
    _Terrain_Size_Line_Edit->set_size(Vector2(50,25));
    _Terrain_Size_Line_Edit->set_editable(true);
    _Terrain_Size_Line_Edit->set_position(Vector2(250,35));
    _Terrain_Size_Line_Edit->connect("text_changed", this, "_on_size_line_edit_entered");
    add_child(_Terrain_Size_Line_Edit);
    _Terrain_Opacity_Line_Edit = memnew(LineEdit);
    _Terrain_Opacity_Line_Edit->set_size(Vector2(50,25));
    _Terrain_Opacity_Line_Edit->set_editable(true);
    _Terrain_Opacity_Line_Edit->set_position(Vector2(250, 60));
    _Terrain_Opacity_Line_Edit->connect("text_changed", this, "_on_opacity_line_edit_entered");
    add_child(_Terrain_Opacity_Line_Edit);
    _Terrain_Flatten_Height_Line_Edit = memnew(LineEdit);
    _Terrain_Flatten_Height_Line_Edit->set_size(Vector2(50,25));
    _Terrain_Flatten_Height_Line_Edit->set_editable(false);
    _Terrain_Flatten_Height_Line_Edit->set_position(Vector2(250,85));
    add_child(_Terrain_Flatten_Height_Line_Edit);
    _Terrain_Texture_ItemList = memnew(ItemList);
    _Terrain_Texture_ItemList->set_size(Vector2(448,512));
    _Terrain_Texture_ItemList->set_position(Vector2(325,0));
    _Terrain_Texture_ItemList->set_same_column_width(true);
    _Terrain_Texture_ItemList->set_max_columns(0);
    _Terrain_Texture_ItemList->set_fixed_icon_size(Vector2(32,32));
    _Terrain_Texture_ItemList->clear();
    add_child(_Terrain_Texture_ItemList);
    _Terrain_Brush_ItemList = memnew(ItemList);
    _Terrain_Brush_ItemList->set_size(Vector2(448,512));
    _Terrain_Brush_ItemList->set_position(Vector2(776,0));
    _Terrain_Brush_ItemList->set_same_column_width(true);
    _Terrain_Brush_ItemList->set_max_columns(0);
    _Terrain_Brush_ItemList->set_fixed_icon_size(Vector2(32,32));
    _Terrain_Brush_ItemList->clear();
    add_child(_Terrain_Brush_ItemList);
    _Terrain_Save_To_Image_Button = memnew(Button);
    _Terrain_Save_To_Image_Button->set_text("Save to image...");
    _Terrain_Save_To_Image_Button->set_position(Vector2(1230,0));
    _Terrain_Save_To_Image_Button->set_toggle_mode(false);
    _Terrain_Save_To_Image_Button->set_pressed(false);
    add_child(_Terrain_Save_To_Image_Button);
}

HeightMapBrushPanel::~HeightMapBrushPanel() {

}


