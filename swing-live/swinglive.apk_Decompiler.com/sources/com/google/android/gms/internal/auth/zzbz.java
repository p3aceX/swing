package com.google.android.gms.internal.auth;

import E0.c;
import android.util.Log;
import java.io.UnsupportedEncodingException;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzbz extends c {
    public final byte[] toByteArray() {
        try {
            return toString().getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            Log.e("AUTH", "Error serializing object.", e);
            return null;
        }
    }
}
