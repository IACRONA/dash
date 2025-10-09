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
      // ОПТИМИЗАЦИЯ: Увеличен интервал с 0.01s (100 FPS) до 0.033s (~30 FPS)
      $.Schedule(0.033, Update);
    }
  }

  Update();
}
