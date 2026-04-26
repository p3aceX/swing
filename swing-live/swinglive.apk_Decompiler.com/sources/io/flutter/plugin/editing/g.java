package io.flutter.plugin.editing;

import N2.j;
import android.view.textservice.SentenceSuggestionsInfo;
import android.view.textservice.SpellCheckerSession;
import android.view.textservice.SuggestionsInfo;
import android.view.textservice.TextInfo;
import android.view.textservice.TextServicesManager;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class g implements SpellCheckerSession.SpellCheckerSessionListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0779j f4575a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final TextServicesManager f4576b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public SpellCheckerSession f4577c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public j f4578d;

    public g(TextServicesManager textServicesManager, C0779j c0779j) {
        this.f4576b = textServicesManager;
        this.f4575a = c0779j;
        c0779j.f6969b = this;
    }

    public final void a(String str, String str2, j jVar) {
        if (this.f4578d != null) {
            jVar.a(null, "error", "Previous spell check request still pending.");
            return;
        }
        this.f4578d = jVar;
        Locale localeA = P2.a.a(str);
        if (this.f4577c == null) {
            this.f4577c = this.f4576b.newSpellCheckerSession(null, localeA, this, true);
        }
        this.f4577c.getSentenceSuggestions(new TextInfo[]{new TextInfo(str2)}, 5);
    }

    @Override // android.view.textservice.SpellCheckerSession.SpellCheckerSessionListener
    public final void onGetSentenceSuggestions(SentenceSuggestionsInfo[] sentenceSuggestionsInfoArr) {
        if (sentenceSuggestionsInfoArr.length == 0) {
            this.f4578d.c(new ArrayList());
            this.f4578d = null;
            return;
        }
        ArrayList arrayList = new ArrayList();
        SentenceSuggestionsInfo sentenceSuggestionsInfo = sentenceSuggestionsInfoArr[0];
        if (sentenceSuggestionsInfo == null) {
            this.f4578d.c(new ArrayList());
            this.f4578d = null;
            return;
        }
        for (int i4 = 0; i4 < sentenceSuggestionsInfo.getSuggestionsCount(); i4++) {
            SuggestionsInfo suggestionsInfoAt = sentenceSuggestionsInfo.getSuggestionsInfoAt(i4);
            int suggestionsCount = suggestionsInfoAt.getSuggestionsCount();
            if (suggestionsCount > 0) {
                HashMap map = new HashMap();
                int offsetAt = sentenceSuggestionsInfo.getOffsetAt(i4);
                int lengthAt = sentenceSuggestionsInfo.getLengthAt(i4) + offsetAt;
                map.put("startIndex", Integer.valueOf(offsetAt));
                map.put("endIndex", Integer.valueOf(lengthAt));
                ArrayList arrayList2 = new ArrayList();
                boolean z4 = false;
                for (int i5 = 0; i5 < suggestionsCount; i5++) {
                    String suggestionAt = suggestionsInfoAt.getSuggestionAt(i5);
                    if (!suggestionAt.isEmpty()) {
                        arrayList2.add(suggestionAt);
                        z4 = true;
                    }
                }
                if (z4) {
                    map.put("suggestions", arrayList2);
                    arrayList.add(map);
                }
            }
        }
        this.f4578d.c(arrayList);
        this.f4578d = null;
    }

    @Override // android.view.textservice.SpellCheckerSession.SpellCheckerSessionListener
    public final void onGetSuggestions(SuggestionsInfo[] suggestionsInfoArr) {
    }
}
