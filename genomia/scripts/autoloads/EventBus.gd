extends Node

# Recursos
signal resource_changed(resource_id: String, new_amount: BigNumber)
signal rate_changed(resource_id: String, new_rate: float)

# Productores
signal producer_upgraded(producer_id: String, new_level: int)
signal producer_unlocked(producer_id: String)
signal producer_cycle_completed(producer_id: String)

# Genes y mutantes
signal gene_discovered(gene_id: String)
signal genes_merged(result_gene_id: String)
signal mutant_created(mutant_id: String)

# Minijuegos
signal minigame_unlocked(minigame_id: String)
signal minigame_started(minigame_id: String)
signal minigame_completed(minigame_id: String, reward: Dictionary)
signal minigame_cooldown_ready(minigame_id: String)

# Prestige
signal prestige_available
signal prestige_triggered(credits_earned: float)

# Logros
signal achievement_unlocked(achievement_id: String, title: String)

# Sistema
signal save_completed
signal load_completed(offline_seconds: float)
