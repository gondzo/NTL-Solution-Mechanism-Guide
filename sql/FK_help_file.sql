ALTER TABLE helpTopic ADD CONSTRAINT FK_help_file
FOREIGN KEY (image_id) REFERENCES fileUpload(id);
