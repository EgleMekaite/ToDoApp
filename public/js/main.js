$(document).ready(function(){
    $.fn.extend({
        toggleText: function(a, b){
            return this.text(this.text() == b ? a : b);
        }
    });
    
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
        var list_id = $(this).attr('data-listinfo').split('-')[1];
        if (confirm("Are you sure you want to delete this item?")) {
            window.location.replace('/lists/' + list_id + '/items/' + item_id + '/delete');
        }
    });

    $(document).on('click', '[data-identifyer]', function(){
        var button_id = $(this).attr('data-identifyer').split('-')[1];
        $('#new-'+ button_id).remove();
    });

});