package P3;

import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
public abstract class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Charset f1492a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Charset f1493b;

    static {
        Charset charsetForName = Charset.forName("UTF-8");
        J3.i.d(charsetForName, "forName(...)");
        f1492a = charsetForName;
        J3.i.d(Charset.forName("UTF-16"), "forName(...)");
        J3.i.d(Charset.forName("UTF-16BE"), "forName(...)");
        J3.i.d(Charset.forName("UTF-16LE"), "forName(...)");
        J3.i.d(Charset.forName("US-ASCII"), "forName(...)");
        Charset charsetForName2 = Charset.forName("ISO-8859-1");
        J3.i.d(charsetForName2, "forName(...)");
        f1493b = charsetForName2;
    }
}
