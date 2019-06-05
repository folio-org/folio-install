package com.folio.modules.yaml.builder;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Type;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class YamlBuilder {

    private static final Type MODULE_SIMPLE_DESCRIPTOR_LIST_TYPE = new TypeToken<List<ModuleSimpleDescriptor>>() {
    }.getType();

    private String header;
    private String footer;

    private String defaultTemplate;
    private Map<String, String> moduleToTemplateMapping;

    private YamlBuilder() throws URISyntaxException, IOException {
        ClassLoader classLoader = YamlBuilder.class.getClassLoader();
        header = new String(Files.readAllBytes(Paths.get(classLoader.getResource("header.template").toURI())));
        footer = new String(Files.readAllBytes(Paths.get(classLoader.getResource("footer.template").toURI())));

        moduleToTemplateMapping = new HashMap<>();

        defaultTemplate = new String(Files.readAllBytes(Paths.get(classLoader.getResource("common-sample.template").toURI())));

        String template = new String(Files.readAllBytes(Paths.get(classLoader.getResource("grails-sample.template").toURI())));
        moduleToTemplateMapping.put("mod-agreements", template);
        moduleToTemplateMapping.put("mod-licenses", template);

        template = new String(Files.readAllBytes(Paths.get(classLoader.getResource("mod-authtoken-sample.template").toURI())));
        moduleToTemplateMapping.put("mod-authtoken", template);

        template = new String(Files.readAllBytes(Paths.get(classLoader.getResource("mod-circulation-sample.template").toURI())));
        moduleToTemplateMapping.put("mod-circulation", template);

        template = new String(Files.readAllBytes(Paths.get(classLoader.getResource("mod-inventory-sample.template").toURI())));
        moduleToTemplateMapping.put("mod-inventory", template);
    }


    private List<String> parseModules(String sourceFile) {

        List<ModuleSimpleDescriptor> moduleSimpleDescriptors = null;
        try {
            moduleSimpleDescriptors = new Gson().fromJson(new JsonReader(new FileReader(sourceFile)), MODULE_SIMPLE_DESCRIPTOR_LIST_TYPE);
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        }
        return moduleSimpleDescriptors.stream().map(ModuleSimpleDescriptor::getId).collect(Collectors.toList());

    }

    private String convertToModuleYaml(String moduleDefinition) {
        int delimiter = moduleDefinition.lastIndexOf('-');
        if (delimiter < 1) {
            throw new RuntimeException("Module definition " + moduleDefinition + " error: no '-' delimiter found");
        }

        String moduleName = moduleDefinition.substring(0, delimiter);
        String moduleVersion = moduleDefinition.substring(delimiter + 1);

        String template = moduleToTemplateMapping.getOrDefault(moduleName, defaultTemplate);

        return template.replace("#{module-name}", moduleName).replace("#{image-version}", moduleVersion).replace("#{java-option}", "-Xmx512m");
    }

    private void doIt(String[] args) throws IOException, URISyntaxException {

        String output = null;
        List<String> input = new ArrayList<>();

        for (String s : args) {
            System.out.println("arg: " + s);
            if (s.startsWith("-i")) {
                input.add(s.substring(s.indexOf("=") + 1).trim());
            } else if (s.startsWith("-o")) {
                output = s.substring(s.indexOf("=") + 1).trim();
            }
        }

        System.out.println("Output: " + output);
        input.forEach(s -> System.out.println("Input: " + s));

        String s = input.stream().map(this::parseModules).flatMap(Collection::stream).collect(Collectors.joining("\n"));
        System.out.println("Modules: " + s);

        String yaml = new StringBuilder(header)
                .append(input.stream().map(this::parseModules).flatMap(Collection::stream).map(this::convertToModuleYaml).collect(Collectors.joining()))
                .append(footer)
                .toString();

        Path path = Paths.get(output);
        Files.write(path, yaml.getBytes());

        System.out.println("Done with " + output);

    }

    public static void main(String[] args) throws IOException, URISyntaxException {

        new YamlBuilder().doIt(args);
    }

    public static class ModuleSimpleDescriptor {
        private String id;
        private String action;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getAction() {
            return action;
        }

        public void setAction(String action) {
            this.action = action;
        }
    }
}
