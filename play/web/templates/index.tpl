<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light dark">
    <link rel="stylesheet" href="static/css/pico.min.css">
    <title>FeroGraphe, a new web ChoreGraph approach for the NAO Robot</title>
    <style>
        button {
            border: 2px solid white;
        }
        .btn-posture {
            width: 100%;
        }
        .img-posture {
            margin-top: 64px;
            width: 100%;
        }
        .fig-posture {
            display: flex;
            margin: 1.5em;
            width: 420px;
            border: 2px solid white;
            background-color: #5454A8;
        }
        .btn-form-grid {
            margin-bottom: 23px;
            margin-top: 40px;
        }
    </style>
  </head>
  <body>
    <script>
        async function doFetch(apiEndpoint, args) {
            return await fetch(`/qicli/call/${apiEndpoint}/`, {
                method: "POST",
                body: JSON.stringify({ args: args }),
                headers: {
                    "Content-Type": "application/json",
                }
            }); 
        }
        async function say() {
            let lang = document.getElementById("set-language").value;
            let msg = document.getElementById("text").value;
            await doFetch('ALTextToSpeech.setLanguage', [lang]);
            await doFetch('ALBackgroundMovement.setEnabled', [0]);
            await doFetch('ALTextToSpeech.say', [msg]);
            return false;
        }
        async function animatedSay() {
            const lang = document.getElementById("set-language").value;
            await doFetch('ALTextToSpeech.setLanguage', [lang]);

            const gesture = document.getElementById("set-gesture").value;
            const text =document.getElementById("text").value;
            const msg = `^start(${gesture}) ${text}`;
            
            //await doFetch('ALBackgroundMovement.setEnabled', [1]);
            await doFetch('ALSpeakingMovement.setMode', ["contextual"]);
            await doFetch('ALAnimatedSpeech.say', [msg]);
            return false;
        }

        async function goToPosture(posture) {
            await doFetch('ALRobotPosture.goToPosture', [posture, 0.5]);
            const response = await doFetch('ALRobotPosture.getPosture');
            window.location.reload(); //ULGY: brutto ma necessario per caricare le corrette gestures in questa implementazione lato python
            // Per tempi maturi... const myPosture = await response.json();
            // Per tempi maturi... document.getElementById("my_posture").innerHTML = myPosture;
            return false;
        }
    </script>
    <main class="container">
        <section id="section_status">
          <h2>Ciao sono NAO, e ora sono in posizione <span id="my_posture">{{current_posture}}</span></h2>
        </section>
        <section id="section_speak">
          <h2>Ti posso dire</h2>
          <div class="grid">
            <div>
              <label for="text">Una frase...</label>
              <input type="text" id="text" name="text" placeholder="Scrivi qui">
            </div>
            <div>
              <label for="set-language">con accento...</label>
              <select id="set-language" name="set-language" required="required">
                % for lang in languages:
                    <option value="{{lang}}" {{'selected="selected"' if lang.lower() == 'italian' else ''}}">{{lang}}</option>
                % end
              </select>
            </div>
            <button class="btn-form-grid" onclick="say();">PARLA</button>
          </div>
          <div class="grid">
            <div>
              <label for="set-gesture">con il gesto...</label>
              <select id="set-gesture" name="set-gesture" required="required">
                % animation_basename = "animations/"+current_posture+"/"
                % for i, gesture in enumerate([x[len(animation_basename):] for x in behaviors if animation_basename in x]):
                    <option value="{{animation_basename + gesture}}" {{'selected="selected"' if i == 0 else ''}}">{{gesture}}</option>
                % end
              </select>
            </div>
            <button class="btn-form-grid" onclick="animatedSay();">PARLA ANIMATO</button>
          </div>
          
          
        </section>
        <section id="section_postures">
          <h2>Posso mettermi in una di queste posizioni</h2>
              % for i,posture in enumerate(postures):
               % if i % 3 == 0:
                <div class="grid">
               % end
                 <figure class="fig-posture"
                    % if posture.startswith("Lying"):
                        style="flex-direction: column"
                    % end
                 >
                   <img class="img-posture" src="static/imgs/NAO/posture_{{posture.lower()}}.png"></img>
                   <button class="btn-posture" onclick="goToPosture('{{posture}}');">{{posture}}</button>
                 </figure>
               % if i % 3 == 2 or i == len(postures) - 1:
                </div>
               % end
              % end
        </section>
    </main>
  </body>
</html>
