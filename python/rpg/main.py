import pygame
import random

# Initialize Pygame
pygame.init()

# Screen dimensions
WIDTH, HEIGHT = 800, 600
TILE_SIZE = 40

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)

# Fonts
FONT = pygame.font.Font(None, 36)

# Screen setup
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("2D Text Adventure RPG")

# Clock
clock = pygame.time.Clock()
FPS = 60

# Player class
class Player:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.rect = pygame.Rect(self.x, self.y, TILE_SIZE, TILE_SIZE)
        self.inventory = []

    def move(self, dx, dy):
        self.x += dx * TILE_SIZE
        self.y += dy * TILE_SIZE
        self.rect.topleft = (self.x, self.y)

    def draw(self):
        pygame.draw.rect(screen, BLUE, self.rect)

# NPC class
class NPC:
    def __init__(self, x, y, name, dialogue):
        self.x = x
        self.y = y
        self.name = name
        self.dialogue = dialogue
        self.rect = pygame.Rect(self.x, self.y, TILE_SIZE, TILE_SIZE)

    def draw(self):
        pygame.draw.rect(screen, YELLOW, self.rect)

    def talk(self):
        return random.choice(self.dialogue)

# Item class
class Item:
    def __init__(self, x, y, name):
        self.x = x
        self.y = y
        self.name = name
        self.rect = pygame.Rect(self.x, self.y, TILE_SIZE, TILE_SIZE)

    def draw(self):
        pygame.draw.rect(screen, GREEN, self.rect)

# Game setup
player = Player(WIDTH // 2, HEIGHT // 2)
npcs = [
    NPC(200, 200, "Villager", ["Hello there!", "Nice weather we're having.", "Have you seen the treasure chest?"]),
    NPC(400, 400, "Merchant", ["Would you like to trade?", "I sell the best wares in town.", "Come back anytime."])
]
items = [
    Item(100, 100, "Health Potion"),
    Item(300, 300, "Gold Coin"),
    Item(500, 500, "Magic Scroll")
]

# Dialogue function
def display_dialogue(text):
    dialogue_box = pygame.Rect(50, HEIGHT - 100, WIDTH - 100, 50)
    pygame.draw.rect(screen, BLACK, dialogue_box)
    pygame.draw.rect(screen, WHITE, dialogue_box, 2)
    dialogue_text = FONT.render(text, True, WHITE)
    screen.blit(dialogue_text, (dialogue_box.x + 10, dialogue_box.y + 10))

# Game loop
running = True
current_dialogue = ""
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Player movement
    keys = pygame.key.get_pressed()
    if keys[pygame.K_UP]:
        player.move(0, -1)
    if keys[pygame.K_DOWN]:
        player.move(0, 1)
    if keys[pygame.K_LEFT]:
        player.move(-1, 0)
    if keys[pygame.K_RIGHT]:
        player.move(1, 0)

    # Interaction with NPCs
    for npc in npcs:
        if player.rect.colliderect(npc.rect):
            current_dialogue = npc.talk()

    # Interaction with items
    for item in items[:]:
        if player.rect.colliderect(item.rect):
            player.inventory.append(item.name)
            items.remove(item)
            current_dialogue = f"You picked up a {item.name}!"

    # Drawing
    screen.fill(WHITE)
    player.draw()
    for npc in npcs:
        npc.draw()
    for item in items:
        item.draw()

    # Display dialogue
    if current_dialogue:
        display_dialogue(current_dialogue)

    # Display inventory
    inventory_text = FONT.render(f"Inventory: {', '.join(player.inventory)}", True, BLACK)
    screen.blit(inventory_text, (10, 10))

    pygame.display.flip()
    clock.tick(FPS)

pygame.quit()
