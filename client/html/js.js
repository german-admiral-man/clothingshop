$(document).keyup(function(e) {
	if (e.key === "Escape") {
	  $.post('http://clothingshop/close', JSON.stringify({}));
    }
});

$(document).ready(function() {
	window.addEventListener('message', function(event) {
		var item = event.data;

		if (item.clothing_system == true) {
            openMainMenu()
		} else if (item.clothing_system == false) {
            closeMainMenu()
        }

        if (item.label !== undefined) {
            if (item.type == "outfit") {
                $(".createOutfit").append(`
                <div class="outfitsContainer">
                    <div class="course">
                        <div class="preview">
                            <h2>`+item.label+`</h2>
                            <h3 class="value_`+item.name+`">Value : `+item.defVal+`</h3>
                        </div>
                        <div class="info">
                            <h2>`+item.store+`</h2>
                            <div class="button_container">
                                <button class="button minus-btn disabled" id="minus_`+item.name+`" type="button" onclick="minusCurrentValue('`+item.name+`', '`+item.min+`', '`+item.max+`')">-</button>
                                <input class="`+item.name+`" type="text" min="`+item.min+`" value="`+item.defVal+`" max="`+item.max+`" id="" onchange="ClothValue('`+item.name+`', '`+item.min+`', '`+item.max+`')">
                                <button class="button plus-btn" id="plus_`+item.name+`" type="button" onclick="plusCurrentValue('`+item.name+`', '`+item.min+`', '`+item.max+`')">+</button>
                            </div>
                            <button class="btn" onclick="setCamera('`+item.name+`', '`+item.cam+`')">Kamera</button>
                        </div>
                    </div>
                </div>
                `);
            }
            if (item.type == "save") {
                $(".createOutfit").append(`
                <div class="outfitsContainer">
                    <div class="course">
                        <div class="preview">
                            <h2>`+item.label+`</h2>
                        </div>
                        <div class="info">
                            <h2>`+item.store+`</h2>
                            <h6>Speichere dein Outfit</h6>
                            <button class="btn" onclick="saveOutfit()">Outfit Speichern</button>
                        </div>
                    </div>
                </div>
                `);
            }
        }

        if (item.outfitLabel !== undefined) {
            $(".manageOutfit").append(`
            <div class="manageOutfitsContainer">
                <div class="course">
                    <div class="preview">
                        <h2>`+item.outfitLabel+`</h2>
                    </div>
                    <div class="info">
                        <h2>`+item.name+`</h2>
                        <h6>Wähle eines deiner Outfits aus</h6>
                        <button class="btn" onclick="dressOutfit('`+item.outfitValue+`', '`+item.outfitLabel+`')">Anziehen</button>
                        <button class="btn" onclick="deleteOutfit('`+item.outfitValue+`', '`+item.outfitLabel+`')">Löschen</button>
                    </div>
                </div>
            </div>
            `);
        }

	});

    $(".button_1").click(function() {
         openCreateOutfit()
         $('.CloathingShopsMenu').css('display', 'none');
    });

    $(".button_2").click(function() {
        openManageOutfit()
        $('.CloathingShopsMenu').css('display', 'none');
    });

    $("#accept_s").click(function() {
        continueSave()
    });

    $("#dismiss_s").click(function() {
         $.post('http://clothingshop/close', JSON.stringify({}));
    });

    $("#dismiss_ss").click(function() {
         $.post('http://clothingshop/close', JSON.stringify({}));
    });

    $("#accept_s2").click(function() {
        let inputValue = $(".inputSetOutName").val()
        if (!inputValue) {
            $.post("http://clothingshop/Notification", JSON.stringify({
                text: "Du musst dem Outfit einen Namen geben, damit es abgespeichert werden kann!"
            }))
            return
        }
        $.post('http://clothingshop/saveOutfit', JSON.stringify({
            name: inputValue,
        }));
        return;
    });

})

function openCreateOutfit() {
    $.post('http://clothingshop/movePed', JSON.stringify({}));
    $('.ContainerSection').css('display', 'block');
    $('.CreateOutfit').css('display', 'block');
}

function openManageOutfit() {
    $.post('http://clothingshop/getSavedOutfits', JSON.stringify({}));
    $('.ContainerSection').css('display', 'block');
    $('.ManageOutfit').css('display', 'block');
}

function openMainMenu() {
    $('.CloathingShopsMenu').css('display', 'block');
}

function closeMainMenu() {
    $('.course').remove();
    $('.CloathingShopsMenu').css('display', 'none');
    $('.ContainerSection').css('display', 'none');
    $('.CreateOutfit').css('display', 'none');
    $('.ManageOutfit').css('display', 'none');
    $('.NotifSection').css('display', 'none');
    $('.notif_succ').css('display', 'none');
    $('.notif_succ_s').css('display', 'none');
    $('.button_1').css('display', 'block');
    $('.button_2').css('display', 'block');
}

function ClothValue(name, min, max) {
    let inputValue = $("." + name).val()
    let result = Math.round(inputValue * 10) / 10;


    if (parseInt(max) > inputValue) {
        if (inputValue > parseInt(min)) {
            $('.value_' + name).text("Value : " + inputValue)

            $.post('http://clothingshop/setCloth', JSON.stringify({
                result: result,
                name: name
            }));
        } else {
            document.querySelector('.' + name).value = parseInt(min)
        }
    } else {
        document.querySelector('.' + name).value = parseInt(max)
    }
}

function ClothValue2(name, min, max) {
    let inputValue = $("." + name).val()
    let result = Math.round(inputValue * 10) / 10;


    $('.value_' + name).text("Value : " + inputValue)

    $.post('http://clothingshop/setCloth', JSON.stringify({
        result: result,
        name: name
    }));
}

function setCamera(name, cam, zoom) {
    $.post('http://clothingshop/setCam', JSON.stringify({
        name: name,
        cam: cam,
        zoom: zoom
    }));
}

function saveOutfit() {
    closeMainMenu()
    $('.NotifSection').css('display', 'block');
    $('.notif_succ').css('display', 'block');
}

function continueSave() {
    closeMainMenu()
    $('.NotifSection').css('display', 'block');
    $('.notif_succ_s').css('display', 'block');
}

function deleteOutfit(outfit, label) {
    $.post('http://clothingshop/deleteOutfit', JSON.stringify({
        outfit: outfit,
        label: label
    }));
    refreshManageOutfits()
}

function dressOutfit(outfit, label) {
    $.post('http://clothingshop/dressOutfit', JSON.stringify({
        outfit: outfit,
        label: label
    }));
}

function refreshManageOutfits() {
    $('.manageOutfitsContainer').remove();
    $.post('http://clothingshop/getSavedOutfits', JSON.stringify({}));
}

function minusCurrentValue(name, min, max) {
    let inputValue = document.querySelector('.' + name).value;

    if (inputValue > parseInt(min)) {
        inputValue--
        document.querySelector('.' + name).value = inputValue
        ClothValue2(name)
    }
}

function plusCurrentValue(name, min, max) {
    let inputValue = document.querySelector('.' + name).value;

    if (parseInt(max) > inputValue) {
        inputValue++
        document.querySelector('.' + name).value = inputValue
        ClothValue2(name)
    }
}