proc(_parse_item, @material, @quantity,
    @item_name = data_name(to_upper(@material))
    return (array(name: @item_name, damage: 0, qty: @quantity, meta:))
)
