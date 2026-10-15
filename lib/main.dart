
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>متابعة دفع الأسماء</title>
<style>
*{box-sizing:border-box}
body{
  margin:0;padding:15px;
  background:#07111f;color:#fff;
  font-family:Tahoma,Arial,sans-serif
}
main{max-width:850px;margin:auto}
header{text-align:center;padding:15px}
h1{color:#38bdf8}
.stats{display:flex;gap:10px;margin:20px 0}
.stat{
  flex:1;text-align:center;padding:13px 5px;
  background:#122238;border:1px solid #23486b;
  border-radius:12px
}
.stat b{display:block;font-size:25px;margin-top:7px}
.people{
  display:grid;grid-template-columns:repeat(2,minmax(0,1fr));
  gap:10px
}
.person{
  background:#122238;border:1px solid #23486b;
  padding:13px;border-radius:12px
}
.person strong{display:block;margin-bottom:12px}
select,input,button{
  padding:11px;border-radius:9px;font:inherit
}
select,input{
  background:#091727;color:white;
  border:1px solid #34506b
}
.person select{width:100%}
input{width:100%;margin-bottom:12px}
button{
  border:0;background:#168cf0;color:white;
  cursor:pointer;font-weight:bold
}
.actions{display:grid;gap:10px;margin-top:20px}
.green{background:#059669}
.gray{background:#334155}
.status{display:block;margin-bottom:10px;font-size:13px}
.paid{color:#6ee7b7}
.pending{color:#cbd5e1}
#preview{display:none;width:100%;margin-top:15px;border-radius:10px}
.note{color:#aab8c9;font-size:13px;line-height:1.8}
@media(max-width:500px){
  .people{grid-template-columns:1fr}
  .stat b{font-size:21px}
}
</style>
</head>
<body>
<main>
<header>
<h1>📋 متابعة دفع الأسماء</h1>
<p>سجّل الدفع وأنشئ صورة للمشاركة</p>
</header>

<section class="stats">
  <div class="stat">تم الدفع ✅<b id="paid">0</b></div>
  <div class="stat">لم يتم<b id="pending">0</b></div>
  <div class="stat">الإجمالي<b id="total">16</b></div>
</section>

<input id="search" placeholder="🔎 ابحث عن اسم...">

<section class="people" id="people"></section>

<div class="actions">
<button class="green" onclick="makeImage()">🖼️ إنشاء صورة القائمة</button>
<button id="saveBtn" class="gray" onclick="saveImage()" disabled>⬇️ حفظ الصورة على الجهاز</button>
<button id="shareBtn" onclick="shareImage()" disabled>📲 مشاركة الصورة / واتساب</button>
</div>

<img id="preview" alt="معاينة قائمة الدفع">

<p class="note">
يتم حفظ الحالات على نفس الجهاز والمتصفح.
بعد إنشاء الصورة، يمكنك حفظها أو مشاركتها.
</p>
</main>

<script>
const names = [
"ابراهيم محمد",
"احمد ايهاب",
"احمد وفيق",
"احمد وليد",
"احمد يحيى",
"ادم جابر",
"ادم طه",
"ابراهيم احمد ابراهيم",
"اسر الديب",
"ياسر جابر",
"اسر انسي",
"اياد لطفي",
"حاتم سامح",
"باسل صلاح",
"حمزه عادل",
"ادهم احمد"
];

const initiallyPaid = [
"احمد ايهاب",
"اسر انسي",
"باسل صلاح",
"ادهم احمد"
];

let status = {};
try {
  status = JSON.parse(
    localStorage.getItem("paymentStatus") || "{}"
  );
} catch(e) {
  status = {};
}

names.forEach(name => {
  if(!["paid","pending"].includes(status[name])){
    status[name] = initiallyPaid.includes(name)
      ? "paid" : "pending";
  }
});

let imageBlob = null;

function saveStatus(){
  try {
    localStorage.setItem(
      "paymentStatus", JSON.stringify(status)
    );
  } catch(e) {}
}

function render(){
  const query = document.getElementById("search")
    .value.trim().toLowerCase();

  const container = document.getElementById("people");
  container.innerHTML = "";

  names.filter(name =>
    name.toLowerCase().includes(query)
  ).forEach(name => {
    const card = document.createElement("div");
    card.className = "person";

    const title = document.createElement("strong");
    title.textContent = name;

    const badge = document.createElement("span");
    badge.className = "status " +
      (status[name] === "paid" ? "paid" : "pending");

    badge.textContent = status[name] === "paid"
      ? "تم الدفع ✅" : "لم يتم الدفع";

    const select = document.createElement("select");

    [
      ["pending","لم يتم الدفع"],
      ["paid","تم الدفع ✅"]
    ].forEach(([value,label]) => {
      const option = document.createElement("option");
      option.value = value;
      option.textContent = label;
      select.appendChild(option);
    });

    select.value = status[name];

    select.onchange = () => {
      status[name] = select.value;
      saveStatus();
      imageBlob = null;
      document.getElementById("saveBtn").disabled = true;
      document.getElementById("shareBtn").disabled = true;
      render();
    };

    card.append(title,badge,select);
    container.appendChild(card);
  });

  const paidCount = names.filter(
    n => status[n] === "paid"
  ).length;

  document.getElementById("paid").textContent = paidCount;
  document.getElementById("pending").textContent =
    names.length - paidCount;
  document.getElementById("total").textContent =
    names.length;
}

document.getElementById("search")
  .addEventListener("input",render);

function makeImage(){
  const canvas = document.createElement("canvas");
  const W = 1000, rowH = 72, H = 350 + names.length/2*rowH;
  canvas.width = W;
  canvas.height = H;

  const ctx = canvas.getContext("2d");
  const gradient = ctx.createLinearGradient(0,0,W,H);
  gradient.addColorStop(0,"#123052");
  gradient.addColorStop(1,"#050b14");
  ctx.fillStyle = gradient;
  ctx.fillRect(0,0,W,H);

  ctx.direction = "rtl";
  ctx.textAlign = "center";
  ctx.fillStyle = "#38bdf8";
  ctx.font = "bold 46px Tahoma";
  ctx.fillText("قائمة متابعة الدفع",W/2,70);

  const paid = names.filter(n=>status[n]==="paid").length;
  ctx.fillStyle = "#ffffff";
  ctx.font = "bold 24px Tahoma";
  ctx.fillText(
    "تم الدفع: "+paid+" | لم يتم: "+(names.length-paid),
    W/2,125
  );

  names.forEach((name,i)=>{
    const col = Math.floor(i/8);
    const row = i%8;
    const x = col===0 ? 40 : 520;
    const y = 165 + row*rowH;

    ctx.fillStyle = "#122238";
    ctx.fillRect(x,y,440,60);

    ctx.textAlign = "right";
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 22px Tahoma";
    ctx.fillText(name,x+420,y+37);

    ctx.textAlign = "left";
    ctx.font = "bold 17px Tahoma";
    ctx.fillStyle = status[name]==="paid"
      ? "#6ee7b7" : "#cbd5e1";
    ctx.fillText(
      status[name]==="paid" ? "تم الدفع ✓" : "لم يتم",
      x+15,y+37
    );
  });

  canvas.toBlob(blob=>{
    if(!blob){
      alert("تعذر إنشاء الصورة.");
      return;
    }
    imageBlob = blob;
    document.getElementById("preview").src =
      URL.createObjectURL(blob);
    document.getElementById("preview").style.display = "block";
    document.getElementById("saveBtn").disabled = false;
    document.getElementById("shareBtn").disabled = false;
  },"image/png");
}

function saveImage(){
  if(!imageBlob) return;

  const url = URL.createObjectURL(imageBlob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "قائمة-الدفع.png";
  a.click();

  setTimeout(()=>URL.revokeObjectURL(url),2000);
}

async function shareImage(){
  if(!imageBlob) return;

  const file = new File(
    [imageBlob],
    "قائمة-الدفع.png",
    {type:"image/png"}
  );

  try{
    if(navigator.canShare &&
       navigator.canShare({files:[file]})){
      await navigator.share({
        title:"قائمة متابعة الدفع",
        text:"قائمة متابعة الدفع",
        files:[file]
      });
    }else{
      alert("احفظ الصورة أولًا ثم أرسلها عبر واتساب.");
    }
  }catch(e){
    if(e.name !== "AbortError"){
      alert("احفظ الصورة ثم أرسلها عبر واتساب.");
    }
  }
}

saveStatus();
render();
</script>
</body>
</html>
