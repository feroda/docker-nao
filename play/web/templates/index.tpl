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
    </style>
  </head>
  <body>
    <main class="container">
        <section id="postures">
          <h2>NAO, vai in posizione</h2>
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
                   <button class="btn-posture" onclick="fetch('/qicli/call/ALRobotPosture.goToPosture/?args={{posture}},1'); return false;">{{posture}}</button>
                 </figure>
               % if i % 3 == 2 or i == len(postures) - 1:
                </div>
               % end
              % end
        </section>
    </main>
  </body>
</html>
