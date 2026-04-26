package com.google.android.gms.common.internal;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class M {
    public static final Uri e = new Uri.Builder().scheme("content").authority("com.google.android.gms.chimera").build();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f3534a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3535b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ComponentName f3536c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f3537d;

    public M(ComponentName componentName) {
        this.f3534a = null;
        this.f3535b = null;
        F.g(componentName);
        this.f3536c = componentName;
        this.f3537d = false;
    }

    public final Intent a(Context context) {
        Bundle bundleCall;
        String str = this.f3534a;
        if (str == null) {
            return new Intent().setComponent(this.f3536c);
        }
        if (this.f3537d) {
            Bundle bundle = new Bundle();
            bundle.putString("serviceActionBundleKey", str);
            try {
                bundleCall = context.getContentResolver().call(e, "serviceIntentCall", (String) null, bundle);
            } catch (IllegalArgumentException e4) {
                Log.w("ConnectionStatusConfig", "Dynamic intent resolution failed: ".concat(e4.toString()));
                bundleCall = null;
            }
            intent = bundleCall != null ? (Intent) bundleCall.getParcelable("serviceResponseIntentKey") : null;
            if (intent == null) {
                Log.w("ConnectionStatusConfig", "Dynamic lookup for intent failed for action: ".concat(String.valueOf(str)));
            }
        }
        return intent == null ? new Intent(str).setPackage(this.f3535b) : intent;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof M)) {
            return false;
        }
        M m4 = (M) obj;
        return F.j(this.f3534a, m4.f3534a) && F.j(this.f3535b, m4.f3535b) && F.j(this.f3536c, m4.f3536c) && this.f3537d == m4.f3537d;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f3534a, this.f3535b, this.f3536c, 4225, Boolean.valueOf(this.f3537d)});
    }

    public final String toString() {
        String str = this.f3534a;
        if (str != null) {
            return str;
        }
        ComponentName componentName = this.f3536c;
        F.g(componentName);
        return componentName.flattenToString();
    }

    public M(String str, String str2, boolean z4) {
        F.d(str);
        this.f3534a = str;
        F.d(str2);
        this.f3535b = str2;
        this.f3536c = null;
        this.f3537d = z4;
    }
}
