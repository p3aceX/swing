package com.google.android.play.core.integrity;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
final class m implements t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private Context f3702a;

    private m() {
    }

    public final m a(Context context) {
        context.getClass();
        this.f3702a = context;
        return this;
    }

    @Override // com.google.android.play.core.integrity.t
    public final o b() {
        Context context = this.f3702a;
        if (context != null) {
            return new o(context, null);
        }
        throw new IllegalStateException(String.valueOf(Context.class.getCanonicalName()).concat(" must be set"));
    }

    public /* synthetic */ m(l lVar) {
    }
}
