function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/*
function wait_for_scene_created(scene, scene_name) {
    _wait_for_scene_created(scene).then(r => console.log("Scene "+ scene_name +" created"))
}
async function _wait_for_scene_created(scene) {
    while (scene.text === undefined) {
        console.log("waiting....")
        await sleep(1000);
    }
}*/

function setInitialText(text, msg) {
    let txt = Messaging.name;
    //if (Messaging.id !== undefined) {
    //    txt = txt + " (" + Messaging.id + ")";
    //}
    text.setText(txt + ', ' + msg);
}


