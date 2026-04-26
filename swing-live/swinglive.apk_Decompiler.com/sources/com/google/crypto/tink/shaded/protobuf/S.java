package com.google.crypto.tink.shaded.protobuf;

import android.util.Log;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class S {
    public static /* synthetic */ int a(int i4) {
        switch (i4) {
            case 1:
                return 1;
            case 2:
                return 2;
            case 3:
                return 4;
            case 4:
                return 8;
            case 5:
                return 16;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return 32;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return 64;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return 128;
            case 9:
                return 256;
            case 10:
                return 512;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return 1024;
            case 12:
                return 2048;
            case 13:
                return 4096;
            case 14:
                return 8192;
            case 15:
                return 16384;
            case 16:
                return 32768;
            case 17:
                return 65536;
            case 18:
                return 131072;
            case 19:
                return 262144;
            case 20:
                return 524288;
            case 21:
                return 1048576;
            case 22:
                return 2097152;
            case 23:
                return 4194304;
            case 24:
                return 8388608;
            case 25:
                return 16777216;
            case 26:
                return 33554432;
            case 27:
                return 67108864;
            case 28:
                return 134217728;
            case 29:
                return 268435456;
            case 30:
                return 536870912;
            case 31:
                return 1073741824;
            case 32:
                return Integer.MIN_VALUE;
            default:
                throw null;
        }
    }

    public static int b(int i4, int i5, int i6) {
        return C0306k.v0(i4) + i5 + i6;
    }

    public static int c(int i4, int i5, int i6, int i7) {
        return C0306k.w0(i4) + i5 + i6 + i7;
    }

    public static String d(int i4, String str) {
        return str + i4;
    }

    public static /* synthetic */ String e(Iterable iterable) {
        StringBuilder sb = new StringBuilder();
        Iterator it = iterable.iterator();
        if (it.hasNext()) {
            while (true) {
                sb.append((CharSequence) it.next());
                if (!it.hasNext()) {
                    break;
                }
                sb.append((CharSequence) " ");
            }
        }
        return sb.toString();
    }

    public static String f(String str, String str2) {
        return str + str2;
    }

    public static String g(String str, String str2, String str3) {
        return str + str2 + str3;
    }

    public static String h(StringBuilder sb, String str, String str2) {
        sb.append(str);
        sb.append(str2);
        return sb.toString();
    }

    public static StringBuilder i(String str, int i4, String str2) {
        StringBuilder sb = new StringBuilder(str);
        sb.append(i4);
        sb.append(str2);
        return sb;
    }

    public static void j(String str, int i4, String str2) {
        Log.e(str2, str + i4);
    }
}
