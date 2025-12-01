const std = @import("std");
const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Player {
        return .{
            .position_x = x,
            .position_y = y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn update(self: *Player) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }
        if (self.position_x < 0) {
            self.position_x = 0;
        }
        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRect(self: Player) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: Player) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Bullet {
        return .{
            .position_x = x,
            .position_y = y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn update(self: *Bullet) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y + self.height < 0) {
                self.active = false;
            }
        }
    }

    pub fn getRect(self: Bullet) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: Bullet) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
    }
};

const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) EnemyBullet {
        return .{
            .position_x = x,
            .position_y = y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .active = false,
        };
    }

    pub fn update(self: *EnemyBullet, screenHeight: i32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y + self.height > @as(f32, @floatFromInt(screenHeight))) {
                self.active = false;
            }
        }
    }

    pub fn getRect(self: EnemyBullet) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: EnemyBullet) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.yellow,
            );
        }
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Invader {
        return .{
            .position_x = x,
            .position_y = y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
    }

    pub fn update(self: *Invader, dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }

    pub fn getRect(self: Invader) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: Invader) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.green,
            );
        }
    }
};

const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Shield {
        return .{
            .position_x = x,
            .position_y = y,
            .width = width,
            .height = height,
            .health = 10,
        };
    }

    pub fn getRect(self: Shield) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: Shield) void {
        if (self.health <= 0) return;
        const alpha: u8 = @intCast(std.math.clamp(self.health * 25, 0, 255));

        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.init(128, 128, 128, alpha),
        );
    }
};

const GameConfig = struct {
    // screen
    const screenWidth = 800;
    const screenHeight = 600;
    // player
    const playerWidth = 50.0;
    const playerHeight = 30.0;
    // bullets
    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;
    const maxEnemyBullets = 20;
    const enemyShootDelay = 60;
    const enemyShootChance = 5;
    // invaders
    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;
    const invaderSpeed = 5.0;
    const invaderMoveDelay = 30;
    const invaderDropDistance = 20.0;
    // shields
    const shieldCount = 4;
    const shieldWidth = 80.0;
    const shieldHeight = 60.0;
    const shieldStartX = 150.0;
    const shieldY = 450.0;
    const shieldSpacing = 150.0;
};

const GameState = struct {
    enemy_shoot_timer: i32,
    invader_direction: f32,
    invader_move_timer: i32,
    score: i32,
    game_over: bool,
    game_won: bool,
    player: Player,
    shields: [GameConfig.shieldCount]Shield,
    invaders: [GameConfig.invaderRows][GameConfig.invaderCols]Invader,
    bullets: [GameConfig.maxBullets]Bullet,
    enemyBullets: [GameConfig.maxEnemyBullets]EnemyBullet,

    pub fn init() GameState {
        return .{
            .enemy_shoot_timer = 0,
            .invader_direction = 1.0,
            .invader_move_timer = 0,
            .score = 0,
            .game_over = false,
            .game_won = false,
            .player = initPlayer(),
            .shields = initShields(),
            .bullets = initBullets(),
            .enemyBullets = initEnemyBullets(),
            .invaders = initInvaders(),
        };
    }

    fn initPlayer() Player {
        return Player.init(
            @as(f32, @floatFromInt(GameConfig.screenWidth)) / 2 - GameConfig.playerWidth / 2,
            @as(f32, @floatFromInt(GameConfig.screenHeight)) - 60.0,
            GameConfig.playerWidth,
            GameConfig.playerHeight,
        );
    }

    fn initShields() [GameConfig.shieldCount]Shield {
        var shields: [GameConfig.shieldCount]Shield = undefined;
        for (&shields, 0..) |*shield, i| {
            shield.* = Shield.init(
                GameConfig.shieldStartX + @as(f32, @floatFromInt(i)) * GameConfig.shieldSpacing,
                GameConfig.shieldY,
                GameConfig.shieldWidth,
                GameConfig.shieldHeight,
            );
        }
        return shields;
    }

    fn initBullets() [GameConfig.maxBullets]Bullet {
        var bullets: [GameConfig.maxBullets]Bullet = undefined;
        for (&bullets) |*bullet| {
            bullet.* = Bullet.init(0.0, 0.0, GameConfig.bulletWidth, GameConfig.bulletHeight);
        }
        return bullets;
    }

    fn initEnemyBullets() [GameConfig.maxEnemyBullets]EnemyBullet {
        var enemyBullets: [GameConfig.maxEnemyBullets]EnemyBullet = undefined;
        for (&enemyBullets) |*bullet| {
            bullet.* = EnemyBullet.init(0.0, 0.0, GameConfig.bulletWidth, GameConfig.bulletHeight);
        }
        return enemyBullets;
    }

    fn initInvaders() [GameConfig.invaderRows][GameConfig.invaderCols]Invader {
        var invaders: [GameConfig.invaderRows][GameConfig.invaderCols]Invader = undefined;
        for (&invaders, 0..) |*row, i| {
            for (row, 0..) |*invader, j| {
                invader.* = Invader.init(
                    GameConfig.invaderStartX + @as(f32, @floatFromInt(j)) * GameConfig.invaderSpacingX,
                    GameConfig.invaderStartY + @as(f32, @floatFromInt(i)) * GameConfig.invaderSpacingY,
                    GameConfig.invaderWidth,
                    GameConfig.invaderHeight,
                );
            }
        }
        return invaders;
    }
};

pub fn main() !void {
    const c = GameConfig;
    rl.initWindow(c.screenWidth, c.screenHeight, "Zig Invaders");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var s = GameState.init();

    main_loop: while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (s.game_over) {
            const gameOverText = "GAME OVER!";
            const finalScoreText = rl.textFormat("Final Score: %d", .{s.score});
            const gameOverWidth = rl.measureText(gameOverText, 40);
            const finalScoreWidth = rl.measureText(finalScoreText, 30);
            rl.drawText(gameOverText, c.screenWidth / 2 - @divTrunc(gameOverWidth, 2), c.screenHeight / 2 - 40, 40, rl.Color.red);
            rl.drawText(finalScoreText, c.screenWidth / 2 - @divTrunc(finalScoreWidth, 2), c.screenHeight / 2 + 10, 30, rl.Color.white);
            const restartText = "Press ENTER to restart or ESC to quit";
            const restartWidth = rl.measureText(restartText, 20);
            rl.drawText(restartText, c.screenWidth / 2 - @divTrunc(restartWidth, 2), c.screenHeight - 60, 20, rl.Color.gray);
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                s = GameState.init();
            }
            continue;
        }

        if (s.game_won) {
            const winText = "YOU WIN!";
            const finalScoreText = rl.textFormat("Final Score: %d", .{s.score});
            const gameOverWidth = rl.measureText(winText, 40);
            const finalScoreWidth = rl.measureText(finalScoreText, 30);
            rl.drawText(winText, c.screenWidth / 2 - @divTrunc(gameOverWidth, 2), c.screenHeight / 2 - 40, 40, rl.Color.gold);
            rl.drawText(finalScoreText, c.screenWidth / 2 - @divTrunc(finalScoreWidth, 2), c.screenHeight / 2 + 10, 30, rl.Color.white);
            const restartText = "Press ENTER to restart or ESC to quit";
            const restartWidth = rl.measureText(restartText, 20);
            rl.drawText(restartText, c.screenWidth / 2 - @divTrunc(restartWidth, 2), c.screenHeight - 60, 20, rl.Color.gray);
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                s = GameState.init();
            }
            continue;
        }

        // UPDATE
        // ===============================================================
        s.player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&s.bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = s.player.position_x + s.player.width / 2 - c.bulletWidth / 2;
                    bullet.position_y = s.player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }
        bullet_loop: for (&s.bullets) |*bullet| {
            bullet.update();

            if (bullet.active) {
                for (&s.invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive and bullet.getRect().intersects(invader.getRect())) {
                            invader.alive = false;
                            bullet.active = false;
                            s.score += 10;
                            continue :bullet_loop;
                        }
                    }
                }

                for (&s.enemyBullets) |*enemyBullet| {
                    if (enemyBullet.active and bullet.getRect().intersects(enemyBullet.getRect())) {
                        enemyBullet.active = false;
                        bullet.active = false;
                        s.score += 5;
                        continue :bullet_loop;
                    }
                }

                for (&s.shields) |*shield| {
                    if (shield.health > 0 and bullet.getRect().intersects(shield.getRect())) {
                        shield.health -= 1;
                        bullet.active = false;
                        continue :bullet_loop;
                    }
                }
            }
        }
        enemy_bullet_loop: for (&s.enemyBullets) |*enemyBullet| {
            enemyBullet.update(c.screenHeight);

            if (enemyBullet.active) {
                for (&s.shields) |*shield| {
                    if (shield.health > 0 and enemyBullet.getRect().intersects(shield.getRect())) {
                        shield.health -= 1;
                        enemyBullet.active = false;
                        continue :enemy_bullet_loop;
                    }
                }

                if (enemyBullet.getRect().intersects(s.player.getRect())) {
                    enemyBullet.active = false;
                    s.game_over = true;
                    continue :main_loop;
                }
            }
        }
        s.enemy_shoot_timer += 1;
        if (s.enemy_shoot_timer >= c.enemyShootDelay) {
            s.enemy_shoot_timer = 0;

            for (&s.invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive and rl.getRandomValue(0, 100) < c.enemyShootChance) {
                        for (&s.enemyBullets) |*enemyBullet| {
                            if (!enemyBullet.active) {
                                enemyBullet.position_x = invader.position_x + invader.width / 2 - c.bulletWidth / 2;
                                enemyBullet.position_y = invader.position_y + invader.height;
                                enemyBullet.active = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
        s.invader_move_timer += 1;
        if (s.invader_move_timer >= c.invaderMoveDelay) {
            s.invader_move_timer = 0;
            var hit_edge = false;

            invaders_loop: for (&s.invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        if (invader.getRect().intersects(s.player.getRect())) {
                            s.game_over = true;
                            continue :main_loop;
                        }

                        const next_x = invader.position_x + c.invaderSpeed * s.invader_direction;
                        if (next_x < 10 or (next_x + invader.width) > @as(f32, @floatFromInt(c.screenWidth)) - 10) {
                            hit_edge = true;
                            break :invaders_loop;
                        }
                    }
                }
            }
            if (hit_edge) s.invader_direction *= -1.0;
            const drop_distance: f32 = if (hit_edge) c.invaderDropDistance else 0;
            for (&s.invaders) |*row| {
                for (row) |*invader| {
                    invader.update(c.invaderSpeed * s.invader_direction, drop_distance);
                }
            }
        }
        var all_invaders_dead = true;
        outer_loop: for (&s.invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    all_invaders_dead = false;
                    break :outer_loop;
                }
            }
        }
        if (all_invaders_dead) s.game_won = true;

        // DRAW
        // ===============================================================
        s.player.draw();
        for (&s.shields) |*shield| shield.draw();
        for (&s.bullets) |*bullet| bullet.draw();
        for (&s.enemyBullets) |*enemyBullet| enemyBullet.draw();
        for (&s.invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        const text = "Zig Invaders -- SPACE to shoot, ARROW KEYS to move, ESC to quit";
        rl.drawText(text, 20, 20, 20, rl.Color.green);

        const scoreText = rl.textFormat("Score: %d", .{s.score});
        rl.drawText(scoreText, 20, c.screenHeight - 20, 20, rl.Color.white);
    }
}
