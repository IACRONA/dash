function AnimateCounter(panel, min, max, duration, { pre, after }) {
  const startTime = Game.Time(); // текущее время в секундах
  const range = max - min;

  function Update() {
    const now = Game.Time();

    const elapsed = now - startTime;
    const progress = Math.min(elapsed / (duration / 1000), 1); // делим на 1000, чтобы перевести duration в секунды
    const currentValue = Math.floor(min + range * progress);

    panel.text = `${pre || ""}${currentValue.toString()}${after || ""}`;

    if (progress < 1) {
      $.Schedule(0.01, Update); // вызываем снова через 10 мс
    }
  }

  Update();
}
