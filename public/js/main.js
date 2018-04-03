$(document).ready(function(){
    var id_num = 1;
    $('#add-item').on('click', function(){
        var template_text = $('#item_template').html();
        $('#items_list').before(template_text);
        $('.template').removeClass('template').attr('id', 'new-' + id_num);
        $('.delete-unsaved').removeClass('delete-unsaved').attr('data-identifyer', 'delete_unsaved-' + id_num);
        id_num++;
    });

    $('[data-name]').each(function(){
        if ($(this).attr('data-name') == 'true') {
        item_id_num = $(this).attr('id').split('-')[1];
        $('#item-' + item_id_num + ' > i').addClass('glyphicon-star');
        $('#row-' + item_id_num).addClass('starred');
        } 
    });

    $('.delete').on('click', function(){
        var item_id = $(this).attr('id').split('-')[1];
        if (confirm("Are you sure you want to delete this item?")) {
            window.location.replace('/delete/item/' + item_id + '');
        }
    });

    $(document).on('click', '[data-identifyer]', function(){
        var button_id = $(this).attr('data-identifyer').split('-')[1];
        $('#new-'+ button_id).remove();
    });
});