const fs = require("fs");
const path = require("path");

class InfoController {
  getHeroUpgradeData = async (req, res) => {
    try {
      const heroesPath = path.join(__dirname, "../talents/heroes");
      
      if (!fs.existsSync(heroesPath)) {
        return res.status(404).json({ error: 'Heroes directory not found' });
      }
      
      const files = fs.readdirSync(heroesPath);
      const heroesData = {};
      
      for (const file of files) {
        if (file.endsWith('.txt')) {
          try {
            const filePath = path.join(heroesPath, file);
            const content = fs.readFileSync(filePath, 'utf8');
            const parsed = this.parseKV(content);
            const heroName = path.basename(file, '.txt');
            heroesData[heroName] = parsed;
          } catch (fileError) {
            console.error(`Error processing file ${file}:`, fileError);
            // Продолжаем обработку других файлов
          }
        }
      }

      return res.json(heroesData);
    } catch (error) {
      console.error('Error in getHeroUpgradeData:', error);
      return res.status(500).json({ error: 'Failed to read heroes data', details: error.message });
    }
  }

  parseKV = (content) => {
    try {
      const lines = content.split('\n');
      const result = {};
      let currentKey = null;
      let depth = 0;
      let currentObject = result;
      const stack = [result];

      lines.forEach((line, index) => {
        line = line.trim();
        
        if (!line || line.startsWith('//')) return;

        if (line.includes('{')) {
          depth++;
          if (currentKey) {
            currentObject[currentKey] = {};
            stack.push(currentObject);
            currentObject = currentObject[currentKey];
            currentKey = null;
          }
        } else if (line.includes('}')) {
          depth--;
          if (stack.length > 0) {
            currentObject = stack.pop();
          }
        } else {
          const kvMatch = line.match(/"([^"]+)"\s+"([^"]+)"/);
          const keyMatch = line.match(/"([^"]+)"/);
          
          if (kvMatch) {
            const [_, key, value] = kvMatch;
            currentObject[key] = value;
          } else if (keyMatch) {
            currentKey = keyMatch[1];
          }
        }
      });

      return result;
    } catch (error) {
      throw new Error(`Failed to parse KV format: ${error.message}`);
    }
  }
}

module.exports = new InfoController();

