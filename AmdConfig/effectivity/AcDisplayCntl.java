package effectivity;
import javax.servlet.jsp.*;

public class AcDisplayCntl 
{ 
	private String acBy;
	private String name;
	private String onChange;
	private String htmlStr = "";
	private JspWriter out;

	public AcDisplayCntl(String defaultView, String name, String onChange)
	{
		setBy(defaultView);
		setName(name);
		setOnChange(onChange);
	}

	public AcDisplayCntl(String defaultView, String name)
	{
		setBy(defaultView);
		setName(name);
	}

	public AcDisplayCntl()
	{
		setBy("p_no");
		setName("acBy");
	}

	public void setBy(String pBy)
	{
		acBy = pBy;
	}

	public String getBy()
	{
		return acBy.toLowerCase();
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getName()
	{
		return name;	
	}

	public String isSelected(String pIn)
	{
		if (pIn.equalsIgnoreCase(getBy()))
		{
			return "selected ";
		}
		else
		{
			return " ";
		}
	}

	public void setOnChange(String onChange)
	{
		this.onChange = onChange;
	}

	public String getOnChange()
	{
		if ((onChange == null) || onChange.equals(""))
		{
			return " "; 
		}
		else
		{
			return " onChange=\"" + onChange + "\"";	
		}
	}

	public void setOut(JspWriter out)
	{
		this.out = out;
		htmlStr  = "";
	}

	public JspWriter getOut()
	{
		return out;
	}

	public void genHtml() throws Exception
	{
		printHtml("<table cellspacing=0 cellpadding=0><tr><td valign=center>Display Aircraft by:&nbsp;</td>");
		printHtml("<td valign=center><select name=\"" + getName() + "\"" + getOnChange() + ">");
		printHtml("<option value=ac_no "   + isSelected("ac_no")   + ">AC_NO");
		printHtml("<option value=bun "     + isSelected("bun")     + ">BUN");
		printHtml("<option value=fsn "     + isSelected("fsn")     + ">FSN");
		printHtml("<option value=fus "     + isSelected("fus")     + ">FUS");
		printHtml("<option value=p_no "    + isSelected("p_no")    + ">P_NO");
		printHtml("<option value=tail_no " + isSelected("tail_no") + ">TAIL_NO");
		printHtml("</select></td></tr></table>");
	}

	void printHtml(String pHtml) throws Exception
	{
		if (out != null)
			out.println(pHtml);

		htmlStr = htmlStr + pHtml;
	}

	public String getHtml()
	{
		return htmlStr;
	}
}
	
