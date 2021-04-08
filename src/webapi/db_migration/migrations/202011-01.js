const Sequelize = require('sequelize')

module.exports = {
    up: async (query) => {
        await query.createTable('items', {
                id: {
                    type: Sequelize.INTEGER,
                    primaryKey: true,
                    autoIncrement: true,
                    allowNull: false
                },
                createdAt: Sequelize.DATE,
                updatedAt: Sequelize.DATE,
                name: Sequelize.STRING
            }
        )
    },
    down: async (query) => {
        await query.dropTable('items');
    }
}