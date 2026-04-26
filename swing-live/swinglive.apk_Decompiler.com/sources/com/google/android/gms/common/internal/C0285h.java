package com.google.android.gms.common.internal;

import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0285h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Set f3557a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Set f3558b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Map f3559c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f3560d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final O0.a f3561f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public Integer f3562g;

    public C0285h(Set set, String str, String str2) {
        O0.a aVar = O0.a.f1441a;
        Set setUnmodifiableSet = set == null ? Collections.EMPTY_SET : Collections.unmodifiableSet(set);
        this.f3557a = setUnmodifiableSet;
        Map map = Collections.EMPTY_MAP;
        this.f3559c = map;
        this.f3560d = str;
        this.e = str2;
        this.f3561f = aVar;
        HashSet hashSet = new HashSet(setUnmodifiableSet);
        Iterator it = map.values().iterator();
        if (it.hasNext()) {
            it.next().getClass();
            throw new ClassCastException();
        }
        this.f3558b = Collections.unmodifiableSet(hashSet);
    }
}
