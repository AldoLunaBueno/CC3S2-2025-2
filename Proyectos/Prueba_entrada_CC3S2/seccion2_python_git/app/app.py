# Implementa la función summarize y el CLI.
# Requisitos:
# - summarize(nums) -> dict con claves: count, sum, avg
# - Valida que nums sea lista no vacía y elementos numéricos (acepta strings convertibles a float).
# - CLI: python -m app "1,2,3" imprime: sum=6.0 avg=2.0 count=3

def summarize(nums):  # TODO: tipado opcional
    # raise NotImplementedError("Implementa summarize según el enunciado")
    if not isinstance(nums, list):
        raise TypeError("'nums' es una lista.")
    if not nums:
        raise ValueError("'nums' es una lista vacía.")
    int
    try:
        nums = [float(n) for n in nums]
    except ValueError:
        raise ValueError("'nums' contiene un elemento no numérico.")
    
    count = len(nums)
    nums_sum = sum(nums)
    avg = nums_sum / count
    
    return {"count": count, "sum": nums_sum, "avg": avg}

def cli(argv):
    if len(argv) < 1:
        print("Uso: python -m app \"1,2,3\"")
    
    raw = argv[0]
    items = [p.strip() for p in raw.split(",") if p.strip()]
    response = summarize(items)
    
    print(f"sum={response['sum']} avg={response['avg']} count={response['count']}")

    
if __name__ == "__main__":
    import sys
    cli(sys.argv[1:])
