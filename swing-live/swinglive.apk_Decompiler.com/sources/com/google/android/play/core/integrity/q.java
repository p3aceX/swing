package com.google.android.play.core.integrity;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
final class q implements ai {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private Context f3711a;

    private q() {
    }

    public final q a(Context context) {
        context.getClass();
        this.f3711a = context;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ai
    public final s b() {
        Context context = this.f3711a;
        if (context != null) {
            return new s(context, null);
        }
        throw new IllegalStateException(String.valueOf(Context.class.getCanonicalName()).concat(" must be set"));
    }

    public /* synthetic */ q(p pVar) {
    }
}
