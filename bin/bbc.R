####  BBC cookbook to make the process of creating publication-ready graphics 
####  using R’s ggplot2 library a more reproducible process.
####  Source: https://bbc.github.io/rcookbook/

#devtools::install_github('bbc/bbplot')  #Run this for the first time to install the bb package

if(!require(pacman))install.packages("pacman")

pacman::p_load('dplyr', 'tidyr', 'gapminder',
               'ggplot2',  'ggalt',
               'forcats', 'R.utils', 'png', 
               'grid', 'ggpubr', 'scales',
               'bbplot')


##########################################################
#Line
##########################################################

#Data for chart from gapminder package
line_df <- gapminder %>%
  filter(country == "Malawi") 

#Make plot
line <- ggplot(line_df, aes(x = year, y = lifeExp)) +
  geom_line(colour = "#1380A1", size = 1) +
  geom_hline(yintercept = 0, size = 1, colour = "#333333") +
  bbc_style() +
  labs(title = "Living longer",
       subtitle = "Life expectancy in Malawi 1952-2007")

##########################################################
#Multiple Line
##########################################################

multiple_line_df <- gapminder %>%
  filter(country == "China" | country == "United States") 

#Make plot
multiple_line <- ggplot(multiple_line_df, aes(x = year, y = lifeExp, colour = country)) +
  geom_line(size = 1) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_colour_manual(values = c("#FAAB18", "#1380A1")) +
  bbc_style() +
  labs(title="Living longer",
       subtitle = "Life expectancy in China and the US") +
  geom_hline(yintercept = 10, size = 1, colour = "red", linetype = "dashed")

multiple_line <- multiple_line +
  geom_label(aes(x = 1980, y = 45, label = "I'm quite a long\nannotation over\nthree rows"), 
           hjust = 0, 
           vjust = 0.5, 
           lineheight = 0.8,
           colour = "#555555", 
           fill = "white", 
           label.size = NA, 
           family="Helvetica", 
           size = 6) 

multiple_line + 
  geom_curve(aes(x = 1979, y = 45, xend = 1965, yend = 43), 
                           colour = "#555555", 
                           size=0.5, 
                           curvature = -0.2,
                           arrow = arrow(length = unit(0.03, "npc"))) 

##########################################################
#Bar 
##########################################################

#Prepare data
bar_df <- gapminder %>%
  filter(year == 2007 & continent == "Africa") %>%
  arrange(desc(lifeExp)) %>%
  head(5)

#Make plot
bars <- ggplot(bar_df, aes(x = country, y = lifeExp)) +
  geom_bar(stat="identity", 
           position="identity", 
           fill="#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  bbc_style() +
  labs(title="Reunion is highest",
       subtitle = "Highest African life expectancy, 2007")

flipped.bars <- bars +  coord_flip() +
  theme(panel.grid.major.x = element_line(color="#cbcbcb"), 
        panel.grid.major.y = element_blank())

flipped.bars <- flipped.bars + scale_y_continuous(limits=c(0,85),
                                  breaks = seq(0, 80, by = 20),
                                  labels = c("0","20", "40", "60", "80 years"))

labelled.bars <- flipped.bars +
  geom_label(aes(x = country, y = lifeExp, label = round(lifeExp, 0)),
             hjust = 1, 
             vjust = 0.5, 
             colour = "white", 
             fill = NA, 
             label.size = NA, 
             family="Helvetica", 
             size = 6)

labelled.bars

#########################################################
#Stacked bar 
#########################################################

#prepare data
stacked_df <- gapminder %>% 
  filter(year == 2007) %>%
  mutate(lifeExpGrouped = cut(lifeExp, 
                              breaks = c(0, 50, 65, 80, 90),
                              labels = c("Under 50", "50-65", "65-80", "80+"))) %>%
  group_by(continent, lifeExpGrouped) %>%
  summarise(continentPop = sum(as.numeric(pop)))

#set order of stacks by changing factor levels
stacked_df$lifeExpGrouped = factor(stacked_df$lifeExpGrouped, levels = rev(levels(stacked_df$lifeExpGrouped)))

#create plot
stacked_bars <- ggplot(data = stacked_df, 
                       aes(x = continent,
                           y = continentPop,
                           fill = lifeExpGrouped)) +
  geom_bar(stat = "identity", 
           position = "fill") +
  bbc_style() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_viridis_d(direction = -1) +
  geom_hline(yintercept = 0, size = 1, colour = "#333333") +
  labs(title = "How life expectancy varies",
       subtitle = "% of population by life expectancy band, 2007") +
  theme(legend.position = "top", 
        legend.justification = "left") +
  guides(fill = guide_legend(reverse = TRUE))

stacked_bars
#########################################################
#Grouped bar
#########################################################

#Prepare data
grouped_bar_df <- gapminder %>%
  filter(year == 1967 | year == 2007) %>%
  select(country, year, lifeExp) %>%
  spread(year, lifeExp) %>%
  mutate(gap = `2007` - `1967`) %>%
  arrange(desc(gap)) %>%
  head(5) %>%
  gather(key = year, 
         value = lifeExp,
         -country,
         -gap) 

#Make plot
grouped_bars <- ggplot(grouped_bar_df, 
                       aes(x = country, 
                           y = lifeExp, 
                           fill = as.factor(year))) +
  geom_bar(stat="identity", position="dodge") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  bbc_style() +
  scale_fill_manual(values = c("#1380A1", "#FAAB18")) +
  labs(title="We're living longer",
       subtitle = "Biggest life expectancy rise, 1967-2007")

grouped_bars
#########################################################
#dumbbell chart
#########################################################

library("ggalt")
library("tidyr")

#Prepare data
dumbbell_df <- gapminder %>%
  filter(year == 1967 | year == 2007) %>%
  select(country, year, lifeExp) %>%
  spread(year, lifeExp) %>%
  mutate(gap = `2007` - `1967`) %>%
  arrange(desc(gap)) %>%
  head(10)

#Make plot
ggplot(dumbbell_df, aes(x = `1967`, xend = `2007`, y = reorder(country, gap), group = country)) + 
  geom_dumbbell(colour = "#dddddd",
                size = 3,
                colour_x = "#FAAB18",
                colour_xend = "#1380A1") +
  bbc_style() + 
  labs(title="We're living longer",
       subtitle="Biggest life expectancy rise, 1967-2007")

#########################################################
#histogram
#########################################################

hist_df <- gapminder %>%
  filter(year == 2007)

ggplot(hist_df, aes(lifeExp)) +
  geom_histogram(binwidth = 5, colour = "white", fill = "#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  bbc_style() +
  scale_x_continuous(limits = c(35, 95),
                     breaks = seq(40, 90, by = 10),
                     labels = c("40", "50", "60", "70", "80", "90 years")) +
  labs(title = "How life expectancy varies",
       subtitle = "Distribution of life expectancy in 2007")

#########################################################
#facets
#########################################################
facet <- gapminder %>%
  filter(continent != "Americas") %>%
  group_by(continent, year) %>%
  summarise(pop = sum(as.numeric(pop)))

facet_plot_free <- ggplot() +
  geom_area(data = facet, aes(x = year, y = pop, fill = continent)) +
  facet_wrap(~continent, scales = "free") + 
  bbc_style() +
  scale_fill_manual(values = c("#FAAB18", "#1380A1","#990000", "#588300")) +
  geom_hline(yintercept = 0, size = 1, colour = "#333333") +
  theme(legend.position = "none",
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(title = "It's all relative",
       subtitle = "Relative population growth by continent,1952-2007")

facet_plot_free
