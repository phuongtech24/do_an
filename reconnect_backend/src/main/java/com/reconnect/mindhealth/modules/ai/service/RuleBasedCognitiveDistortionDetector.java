package com.reconnect.mindhealth.modules.ai.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import org.springframework.stereotype.Component;

@Component
public class RuleBasedCognitiveDistortionDetector {

    /**
     * Returns a list of distortion codes (stable identifiers) for UI mapping.
     * Codes:
     * - CATASTROPHIZING
     * - MIND_READING
     * - ALL_OR_NOTHING
     * - OVERGENERALIZATION
     * - EMOTIONAL_REASONING
     * - LABELING
     * - DISQUALIFYING_POSITIVE
     * - MAGNIFICATION_MINIMIZATION
     * - MENTAL_FILTER
     * - PERSONALIZATION
     * - SHOULD_MUST
     * - TUNNEL_VISION
     */
    public List<String> detect(String situation, String automaticThought, int max) {
        String text = normalize((situation == null ? "" : situation) + " " + (automaticThought == null ? "" : automaticThought));
        if (text.isBlank()) {
            return List.of();
        }

        Set<String> out = new LinkedHashSet<>();

        if (containsAny(text, List.of(
                "toi chac chan", "chac chan se", "toi se that bai", "toi se lam hong", "toi se bi", "toi se mat",
                "toi khong the", "the nao cung hong", "se rat te", "se thanh tham hoa", "se xau ho", "se cuoi toi",
                "se che toi", "se coi thuong toi", "se xay ra dieu te nhat"))) {
            out.add("CATASTROPHIZING");
        }
        if (containsAny(text, List.of(
                "ho se nghi", "mo i nguoi se nghi", "ai cung nghi", "ho chac nghi", "ho ghe t", "ho khinh",
                "ho coi thuong", "ho dang nghi", "nguoi ta se nghi", "nguoi khac se nghi", "ho danh gia toi",
                "ho thay toi kem coi", "ho nghi toi ky cuc", "ho thay toi ngoc"))) {
            out.add("MIND_READING");
        }
        if (containsAny(text, List.of("luon luon", "khong bao gio", "hoan toan", "tat ca", "khong con gi", "luc nao cung"))) {
            out.add("ALL_OR_NOTHING");
        }
        if (containsAny(text, List.of("lan nao cung", "luc nao cung", "toan la", "luc nao", "tai sao luc nao"))) {
            out.add("OVERGENERALIZATION");
        }
        if (containsAny(text, List.of("toi cam thay nen", "toi thay nen", "cam thay nhu the nen", "vi toi cam thay"))) {
            out.add("EMOTIONAL_REASONING");
        }
        if (containsAny(text, List.of(
                "toi la", "minh la", "do la toi", "vo dung", "vo gia tri", "that bai", "ngu ngoc",
                "kem coi", "bat tai", "yeu kem", "te hai", "xau xi", "ky cuc"))) {
            out.add("LABELING");
        }
        if (containsAny(text, List.of("chi la may man", "do may man", "khong dang ke", "khong tinh", "ai cung lam duoc", "chua co gi gioi", "khong co gi dac biet"))) {
            out.add("DISQUALIFYING_POSITIVE");
        }
        if (containsAny(text, List.of("qua te", "kinh khung", "khung khiep", "toi te nhat", "chuyen nho thoi", "khong quan trong", "chang co gi hay"))) {
            out.add("MAGNIFICATION_MINIMIZATION");
        }
        if (containsAny(text, List.of("chi thay", "chi nho", "chi nghi den", "chi tap trung", "toan nhin thay diem xau", "moi thu deu xau"))) {
            out.add("MENTAL_FILTER");
        }
        if (containsAny(text, List.of("la loi cua toi", "tai toi", "do toi", "vi toi nen", "toi lam ho", "toi khien ho", "tat ca la loi cua toi"))) {
            out.add("PERSONALIZATION");
        }
        if (containsAny(text, List.of(
                "toi phai", "minh phai", "toi nen", "minh nen", "bat buoc phai", "khong duoc phep", "phai luon",
                "nen luon", "phai that gioi", "phai noi tron tru", "phai lam tot", "khong duoc sai", "khong duoc vap",
                "khong duoc run", "khong duoc lo"))) {
            out.add("SHOULD_MUST");
        }
        if (containsAny(text, List.of("chi co dieu xau", "khong co gi tot", "toan dieu te", "chi nhin thay that bai", "tat ca deu te", "moi thu deu vo nghia"))) {
            out.add("TUNNEL_VISION");
        }

        List<String> list = new ArrayList<>(out);
        if (max <= 0) {
            max = 3;
        }
        if (list.size() > max) {
            return list.subList(0, max);
        }
        return list;
    }

    private boolean containsAny(String haystack, List<String> needles) {
        for (String n : needles) {
            if (n != null && !n.isBlank() && haystack.contains(n)) {
                return true;
            }
        }
        return false;
    }

    private String normalize(String text) {
        if (text == null) {
            return "";
        }
        String lower = text.toLowerCase(Locale.ROOT).trim();
        String decomposed = Normalizer.normalize(lower, Normalizer.Form.NFD);
        String noMarks = decomposed.replaceAll("\\p{M}+", "");
        return noMarks.replaceAll("[^a-z0-9\\s]", " ").replaceAll("\\s+", " ").trim();
    }
}
