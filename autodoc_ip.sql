
-- Add this table to your wordpress installation.
-- This will mantain the ip / Post ID relation
-- --------------------------------------------------------


CREATE TABLE IF NOT EXISTS `autodoc_ip` (
  `ipv4` int(11) unsigned NOT NULL,
  `post_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `autodoc_ip`
  ADD PRIMARY KEY (`ipv4`),
  ADD UNIQUE KEY `post_id` (`post_id`);
