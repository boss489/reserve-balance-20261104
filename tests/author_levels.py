"""One-off deterministic puzzle authoring aid; output is checked-in static JSON."""
import itertools, json, random
from pathlib import Path

rng = random.Random(41429)
names = [
    "첫 번째 추", "바늘의 숨", "작은 약속", "두 사람의 몫", "남겨둔 자리", "빈 접시", "잠긴 서랍",
    "교차하는 무게", "느린 저녁", "봉인된 돌", "낯선 합", "비밀 저울", "기억의 무게", "되돌아오는 손", "한 번 더",
    "긴 그림자", "마지막 예비", "수평의 문",
]
stages = ["새벽의 계량실", "청동 복도", "유리 온실", "밤의 보관소", "별빛 저울"]
sizes = [4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7]
left_slots = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3]
levels = []
incoming = 2
for i, (size, nleft) in enumerate(zip(sizes, left_slots)):
    for attempt in range(100000):
        stones = [incoming] + rng.sample([x for x in range(1, 24) if x != incoming], size - 1)
        # Explicitly designate one of the newly acquired stones as next-room reserve.
        reserve = stones[-1]
        weights = stones[:-1]
        if sum(weights) % 2:
            continue
        solutions = [combo for combo in itertools.combinations(range(size - 1), nleft)
                     if sum(weights[j] for j in combo) * 2 == sum(weights)]
        if not solutions or len(solutions) > 3:
            continue
        # Alternate layout of reserve stone so scanning order does not teach a shortcut.
        stones = stones[1:] + stones[:1] if i % 2 else stones
        # Rotate again to hide the reserve at different positions.
        k = (i * 3) % size
        stones = stones[k:] + stones[:k]
        stage = 1 if i < 3 else 2 if i < 7 else 3 if i < 10 else 4 if i < 15 else 5
        levels.append(dict(stage=stage, title=names[i], stones=stones, reserve=reserve,
                           left_slots=nleft, note=f"{stages[stage-1]} · {i+1:02d}"))
        incoming = reserve
        break
    else:
        raise RuntimeError(i)
path = Path(__file__).resolve().parent.parent / 'levels.json'
path.write_text(json.dumps(levels, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('wrote', path, '18 levels, carry sequence:', [p['reserve'] for p in levels])
